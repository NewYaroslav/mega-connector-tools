# Bridge REST API Documentation

## Overview
This API provides access to our application data and services. It is designed for developers to perform automated tasks.

Base URL: `https://{your-ip}:{your-port}/api/v1`
Replace `{your-ip}` with the IP address of your server and `{your-port}` with the port number configured for the API.

## Authentication
To access the API, you must provide an API token in the header of your requests:

```plaintext
Authorization: Bearer YOUR_API_TOKEN
```

## Error Codes
- `200 OK` - The request was successful.
- `400 Bad Request` - The request was invalid or missing data.
- `401 Unauthorized` - The API token is missing or invalid.
- `403 Forbidden` - The API token does not have sufficient permissions.
- `404 Not Found` - The requested resource was not found.
- `500 Internal Server Error` - An error occurred on the server.

## Endpoints

### GET /ping
Checks the API status.

#### Request

```plaintext
GET https://127.0.0.1:8080/api/v1/ping
```

#### Response

```json
{
    "ok": true,
    "result": {
        "can_trade": true,
        "can_view_info": true,
        "timestamp_ms": 1234567890
    }
}
```
