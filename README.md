Flutter Development Code Challenge
Currency Converter Application
📌 Project Overview

Develop a Currency Converter mobile application using Flutter (Dart) that allows users to view supported currencies, convert between currencies, and display historical exchange rate data.
The application follows Clean Architecture, uses Bloc for state management, and applies best practices in caching, dependency injection, and unit testing.

⚠️ Note:
The originally requested API (free.currencyconverterapi.com) is currently unavailable for the free tier.
Therefore, the application uses ExchangeRate.host, a reliable and well-documented free alternative, while maintaining all original functional requirements.

✅ Functional Requirements
1️⃣ Supported Currencies List

Fetch the list of supported currencies from a remote API.

Each currency should display:

Currency code (e.g. USD)

Currency name (e.g. United States Dollar)

Country flag

On the first app launch:

Fetch the data from the API.

Store the currencies locally in a database.

On subsequent launches:

Load currencies directly from the local database (offline-first approach).

2️⃣ Currency Converter

Allow the user to:

Select a source currency.

Select a target currency.

Enter an amount to convert.

Fetch real-time conversion rates from the API.

Display the converted amount clearly.

3️⃣ Historical Exchange Rates

Display historical exchange rate data for any two selected currencies.

Show exchange rates for the last 7 days.

Present the data in a visual format (e.g. line chart).

🌐 APIs Used in the Project
🔹 Base API Provider

ExchangeRate.host
Official documentation:
👉 https://exchangerate.host/documentation

Chosen because:

Free and reliable

Well-documented

No rate-limit issues for small projects

Supports live, historical, and conversion endpoints

Suitable for demo and production-ready architecture

🔹 API Endpoints Used
1️⃣ Supported Currencies

Purpose:
Fetch all supported currencies and their names.

GET https://api.exchangerate.host/list


Why this endpoint?

Provides a complete list of currency codes and names.

Ideal for caching locally since the data rarely changes.

Example Response:

{
  "success": true,
  "currencies": {
    "USD": "United States Dollar",
    "EUR": "Euro",
    "EGP": "Egyptian Pound"
  }
}

2️⃣ Currency Conversion

Purpose:
Convert an amount from one currency to another.

GET https://api.exchangerate.host/convert
?from=EUR
&to=GBP
&amount=100


Why this endpoint?

Provides accurate and up-to-date conversion results.

Simple response structure.

Ideal for real-time conversion logic.

3️⃣ Historical Exchange Rates (Last 7 Days)

Purpose:
Retrieve historical exchange rates between two currencies.

GET https://api.exchangerate.host/historical
?date=YYYY-MM-DD


OR (preferred for multiple days):

GET https://api.exchangerate.host/timeframe
?start_date=YYYY-MM-DD
&end_date=YYYY-MM-DD
&base=USD
&symbols=EUR


Why this endpoint?

Allows fetching historical data for a specific period.

Perfect for displaying 7-day charts.

Keeps API usage efficient.

4️⃣ Live Rates (Optional)

Purpose:
Fetch current exchange rates for multiple currencies at once.

GET https://api.exchangerate.host/live
&currencies=USD,EUR,GBP


Why this endpoint?

Useful for optimization if multiple conversions are needed.

Optional enhancement, not mandatory.

🏳️ Country Flags

Flags are loaded using FlagCDN:

https://flagcdn.com/w40/{country_code}.png


Why FlagCDN?

Free

Fast CDN

Supports ISO country codes

Easy integration with Flutter image loaders

🧱 Technical Guidelines
1️⃣ Language & Framework

Flutter (Dart)

2️⃣ Architecture

Clean Architecture

Layers:

Data

Domain

Presentation

Why Clean Architecture?

Separation of concerns

Testability

Scalability

Maintainability

3️⃣ State Management

Bloc Pattern

Why Bloc?

Predictable state management

Clear event/state flow

Easy unit testing

4️⃣ Dependency Injection

Use a DI library (e.g. get_it, injectable)

Why DI?

Loose coupling

Better testing

Cleaner codebase

5️⃣ Local Database

SQLite (using sqflite)

Why SQLite?

Lightweight

Offline support

Ideal for caching static data like currencies

6️⃣ Image Loading

cached_network_image

Why this library?

Automatic image caching

Improved performance

Offline image access

7️⃣ Unit Testing

Write unit tests for:

API integration

Business logic (UseCases)

Not required:

UI tests

Golden tests

8️⃣ UI

Use Google Material Design components

Responsive layout

Clear loading, error, and empty states

📌 Deliverables

Public GitHub / GitLab repository

Complete Flutter source code

README with:

Build instructions

Architecture explanation

API usage explanation

Technology justifications

Unit tests