import itertools
import logging
import time
from dataclasses import dataclass
from datetime import UTC, date, datetime, timedelta
from typing import Iterable

import astral
import astral.geocoder
import astral.sun
import dbus
from dbus.mainloop.glib import DBusGMainLoop

TEMPERATURE_DAY = 6500
TEMPERATURE_NIGHT = 4800

logger = logging.getLogger(__name__)


class GammaRelayRs:
    def __init__(self):
        d = dbus.SessionBus().get_object("rs.wl-gammarelay", "/")
        self.gammarelay = dbus.Interface(d, dbus_interface="rs.wl.gammarelay")
        self.properties = dbus.Interface(
            d, dbus_interface="org.freedesktop.DBus.Properties"
        )

    def get_temperature(self) -> int:
        return self.properties.Get("rs.wl.gammarelay", "Temperature")

    def set_temperature(self, val: int):
        logger.info("Set temperature: %dK", val)
        curr = self.get_temperature()
        self.gammarelay.UpdateTemperature(val - curr)


@dataclass
class Event:
    dt: datetime
    name: str
    temperature: int

    @classmethod
    def range(
        cls,
        start: "Event",
        end: "Event",
        step: timedelta,
    ) -> Iterable["Event"]:
        if start.dt >= end.dt:
            return

        yield start
        curr_dt = start.dt + step

        while curr_dt < end.dt:
            ratio = (curr_dt - start.dt) / (end.dt - start.dt)

            yield cls(
                curr_dt,
                f"{start.name}->{end.name} ({int(100 * ratio)}%)",
                int((1 - ratio) * start.temperature + ratio * end.temperature),
            )

            curr_dt += step

        yield end

    @classmethod
    def iter_from(
        cls,
        observer: astral.Observer,
        start_date: date,
    ) -> Iterable["Event"]:
        curr_date = start_date

        while True:
            events = astral.sun.sun(observer, date=curr_date)

            dawn = cls(events["dawn"], "Dawn", TEMPERATURE_NIGHT)
            sunrise = cls(events["sunrise"], "Sunrise", TEMPERATURE_DAY)
            yield from cls.range(dawn, sunrise, timedelta(seconds=30))

            sunset = cls(events["sunset"], "Dawn", TEMPERATURE_DAY)
            dusk = cls(events["dusk"], "Sunrise", TEMPERATURE_NIGHT)
            yield from cls.range(sunset, dusk, timedelta(seconds=30))

            curr_date += timedelta(days=1)


def main():
    logging.basicConfig(
        format="%(asctime)s %(levelname)s %(message)s",
        level="INFO",
    )

    DBusGMainLoop(set_as_default=True)
    gammarelay_rs = GammaRelayRs()
    city = astral.geocoder.lookup("Paris", astral.geocoder.database())
    expected_value = None
    events = Event.iter_from(city.observer, date.today() - timedelta(days=1))

    # Initialize to current expected value
    for event in events:
        if event.dt >= datetime.now(tz=UTC):
            gammarelay_rs.set_temperature(expected_value)
            events = itertools.chain([event], events)
            break

        expected_value = event.temperature

    # Main loop
    for event in events:
        delay = (event.dt - datetime.now(tz=UTC)).total_seconds()
        logger.info("Waiting %.1fs for %s", delay, event.name)
        time.sleep(delay)

        if expected_value != (value := gammarelay_rs.get_temperature()):
            logger.warning(
                "Temperature changed to %d (from %d): exiting",
                value,
                expected_value,
            )
            break

        gammarelay_rs.set_temperature(event.temperature)
        expected_value = event.temperature


if __name__ == "__main__":
    main()
