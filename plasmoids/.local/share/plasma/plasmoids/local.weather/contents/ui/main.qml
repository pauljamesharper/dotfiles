import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    property var current: null
    property var daily: null

    preferredRepresentation: fullRepresentation
    toolTipMainText: Plasmoid.configuration.placeName
    toolTipSubText: !current ? "Loading…" :
        describe(current.weather_code) + "\n"
        + "Feels like " + Math.round(current.apparent_temperature) + "°C\n"
        + "High " + Math.round(daily.temperature_2m_max[0]) + "°  Low " + Math.round(daily.temperature_2m_min[0]) + "°\n"
        + "Humidity " + current.relative_humidity_2m + "%  Wind " + Math.round(current.wind_speed_10m) + " km/h"

    // WMO weather interpretation codes
    function describe(c) {
        if (c === 0) return "Clear"
        if (c <= 2) return "Partly cloudy"
        if (c === 3) return "Overcast"
        if (c <= 48) return "Fog"
        if (c <= 57) return "Drizzle"
        if (c <= 67) return "Rain"
        if (c <= 77) return "Snow"
        if (c <= 82) return "Showers"
        if (c <= 86) return "Snow showers"
        return "Thunderstorm"
    }
    function icon(c, day) {
        const n = day ? "" : "-night"
        if (c === 0) return "weather-clear" + n
        if (c <= 2) return "weather-few-clouds" + n
        if (c === 3) return "weather-overcast"
        if (c <= 48) return "weather-fog"
        if (c <= 57) return "weather-showers-scattered"
        if (c <= 67 || (c >= 80 && c <= 82)) return "weather-showers"
        if (c <= 77 || c === 85 || c === 86) return "weather-snow"
        return "weather-storm"
    }

    function refresh() {
        const req = new XMLHttpRequest()
        req.open("GET", "https://api.open-meteo.com/v1/forecast?latitude=" + Plasmoid.configuration.latitude
                 + "&longitude=" + Plasmoid.configuration.longitude
                 + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,is_day"
                 + "&daily=temperature_2m_max,temperature_2m_min&forecast_days=1&timezone=auto")
        req.onreadystatechange = () => {
            if (req.readyState !== XMLHttpRequest.DONE || req.status !== 200) return
            const d = JSON.parse(req.responseText)
            root.daily = d.daily
            root.current = d.current
        }
        req.send()
    }

    Timer { interval: 15 * 60 * 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }

    fullRepresentation: RowLayout {
        spacing: Kirigami.Units.smallSpacing
        Layout.fillHeight: true
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth

        Kirigami.Icon {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            source: (root.current ? root.icon(root.current.weather_code, root.current.is_day) : "weather-none-available") + "-symbolic"
        }
        PlasmaComponents.Label {
            text: root.current ? Math.round(root.current.temperature_2m) + "°" : "–"
            font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 1.25)
        }
    }
}
