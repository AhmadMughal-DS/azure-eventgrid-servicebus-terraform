# Architecture Diagram — Azure Event-Driven Integration

## Lucid diagram

- **Master Lucid document (all 30 diagrams, icon style):** https://lucid.app/lucidchart/3da75ce3-ea66-4296-81b3-00d20a60435b/edit
- This project is **page 18** of that document.

## Lucid prompt (reusable)

```
Create an Azure architecture diagram titled "Azure Event-Driven Integration".
An Event Publisher publishes to an Event Grid Topic; an event subscription routes
events to a Service Bus Queue; an Azure Functions app is triggered by the queue to
process events. Label the arrows. Clean, professional Azure colors.
```

## Mermaid source

```mermaid
flowchart LR
    Pub([Event Publisher])
    EG[Event Grid Topic]
    SB[Service Bus Queue]
    Func[Azure Functions]
    Pub -->|publish| EG
    EG -->|event subscription| SB
    SB -->|trigger| Func
```
