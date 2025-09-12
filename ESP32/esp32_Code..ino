#include <ArduinoJson.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <HTTPClient.h>
#include <WiFi.h>

const char* ssid = "Your_SSID";
const char* password = "Your_Passowrd";
const char* apiUrl = "Your_API_URL";

IPAddress staticIP(192, 168, 43, 123);
IPAddress gateway(192, 168, 43, 1);
IPAddress subnet(255, 255, 255, 0);
IPAddress dns(8, 8, 8, 8);

AsyncWebServer server(80);

void setup() {
    Serial.begin(115200);
    analogReadResolution(12);

    if (!WiFi.config(staticIP, gateway, subnet, dns)) {
        Serial.println("STA Failed to configure");
    }

    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("Connected to WiFi");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());

    server.on("/get-sensor-data", HTTP_GET, [](AsyncWebServerRequest *request){
        int sensorValue1 = analogRead(32);
        int sensorValue2 = analogRead(33);
        int sensorValue3 = analogRead(34);
        int sensorValue4 = analogRead(35);
        int sensorValue5 = analogRead(36);

        DynamicJsonDocument jsonDocument(200);
        jsonDocument["sensor1"] = sensorValue1;
        jsonDocument["sensor2"] = sensorValue2;
        jsonDocument["sensor3"] = sensorValue3;
        jsonDocument["sensor4"] = sensorValue4;
        jsonDocument["sensor5"] = sensorValue5;

        String requestBody;
        serializeJson(jsonDocument, requestBody);

        HTTPClient http;
        http.begin(apiUrl);
        http.addHeader("Content-Type", "application/json");
        int httpResponseCode = http.POST(requestBody);

        if (httpResponseCode > 0) {
            String response = http.getString();
            Serial.println(response);
            request->send(200, "application/json", response);
        } else {
            Serial.print("Error on sending POST: ");
            Serial.println(httpResponseCode);
            request->send(500);
        }

        http.end();
    });

    server.begin();
}

void loop() {
}