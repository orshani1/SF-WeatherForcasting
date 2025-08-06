# 📘 Weather Forecasting LWC Component

## 👋 Overview

This solution fulfills — and goes beyond — the original demand to display tomorrow’s weather on a record page in Salesforce. It consists of a **Lightning Web Component (LWC)** and an **Apex controller** that fetches weather data from an external API based on a record's geolocation.

## ✅ Original Requirements Recap

1. Display an **icon + text** of **tomorrow’s weather** based on the **record location**.
2. Component should be **placeable on any record page**.
3. When the record is **viewed or its location is updated**, the **weather should update** accordingly.
4. The component should **call a weather service** backend and display **forecast data**.

---

## 🚀 My Approach

### 🧠 Architectural Decision: **Reusable & Metadata-Driven**

Rather than building a hardcoded solution for a single object (e.g., Account), this solution is built to be:

- **Generic** across any object type
- **Configurable** via custom metadata
- **Maintainable** and **scalable** for future needs

---

## 🧩 Key Components

### 1. `LWC_RecordWeatherForcastingCtrl` (Apex Controller)
- Retrieves tomorrow’s weather based on the record's **latitude and longitude**.
- Uses `Callouts_Credentials__c` custom metadata to retrieve the API key.
- Uses `Record_Weather_Location_Fields__mdt` to determine which fields on the record store the geolocation data.
- Returns weather forecast data from the external service (`WeatherAPI.com` or similar).

### 2. `Record_Weather_Location_Fields__mdt` (Custom Metadata)
- Stores the **field API names** for latitude and longitude per object type.
- Makes the solution **low-code configurable** to support any object with geolocation fields.

### 3. Lightning Web Component (LWC)
- Called with `recordId` and uses Apex to fetch weather.
- Displays tomorrow’s weather with icon and description.
- Automatically re-renders if the geolocation fields are updated.

---

## ⚙️ Why This Architecture?

| Feature | Benefit |
|--------|---------|
| **Reusable for any object** | Admins/devs can reuse the same component on different objects (e.g., Account, Contact, Case) |
| **No code changes needed for new objects** | Only metadata configuration is required |
| **Centralized logic** | Easier to test and maintain |
| **Scalable** | Future-proofed for business growth and evolving needs |
| **Declarative + Programmatic hybrid** | Metadata + Apex = clean separation of config and logic |

---

## 💬 Notes & Clarifications

- This implementation **goes beyond the original scope** intentionally to demonstrate scalable architecture thinking.
- The basic demand (weather by record location) is fully covered — but extended to support **multiple object types**.
- This pattern is especially useful in **large orgs** where reusability and configuration are key principles.
- 🔐 A file named **`org_credentials.txt`** is included in the repository to provide login credentials for testing purposes.

---

## 📌 Future Enhancements

- Add geocoding (address → lat/lng) if the record stores a text-based address instead of coordinates.
- Add support for caching daily forecast responses to reduce API calls.
- Build admin UI to manage the metadata (record type → location fields).

---

## 🧪 Test Scenarios

| Test Case | Description |
|-----------|-------------|
| Record with valid coordinates | Weather data should load and display correctly |
| Missing metadata mapping | Component should fail gracefully with a useful error |
| Location updated | New weather forecast should load |
| Unsupported object | Message shown or component hidden |

---

## 🧑‍💼 Interview Justification

In a real-world Salesforce implementation, business demands evolve fast. Designing for reusability, configuration, and separation of concerns leads to more **sustainable systems**. This solution showcases:

- Delivery of all required functionality
- Technical foresight and best practices
- Experience with metadata-driven design — a hallmark of **architect-level thinking**
