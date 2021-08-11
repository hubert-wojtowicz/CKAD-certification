# Multi-Container Pods
## Patterns:
1. Ambassador - for example app that manages configuration of service connections (like different databases per environment)
2. Adapter - for example normalization of logs before sending to log aggregation server
3. Sidecar - logger agent next to application instance

Pod share:
- network 
- storage
- lifecycle