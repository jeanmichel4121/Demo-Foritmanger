# Diagrams

> **Visual guides for FortiManager API concepts and project structure.**

[Home](../README.md) > Diagrams

---

## Available Diagrams

| # | Diagram | Description |
|---|---------|-------------|
| 00 | [Documentation Map](00-documentation-map.d2) | Overview of documentation structure and reading flow |
| 01 | [Architecture Overview](01-architecture-overview.d2) | FortiManager architecture and components |
| 02 | [JSON-RPC Flow](02-json-rpc-flow.d2) | Request/Response flow for JSON-RPC API |
| 03 | [Authentication Methods](03-authentication-methods.d2) | Session vs Bearer token authentication |
| 04 | [Object Hierarchy](04-object-hierarchy.d2) | FortiManager object types and relationships |
| 05 | [Policy Installation Workflow](05-policy-installation-workflow.d2) | Steps for deploying policies to FortiGates |
| 06 | [Learning Progression](06-learning-progression.d2) | Recommended path from beginner to expert |
| 07 | [CRUD Methods](07-crud-methods.d2) | Create, Read, Update, Delete operations |
| 08 | [Error Codes](08-error-codes.d2) | Common error codes and meanings |
| 09 | [URL Structure](09-url-structure.d2) | API URL patterns and hierarchy |
| 10 | [Project Structure](10-project-structure.d2) | This repository's folder organization |

---

## Diagram Categories

### Getting Started

| Diagram | Best For |
|---------|----------|
| Documentation Map | Understanding what to read and when |
| Learning Progression | Planning your learning path |
| Project Structure | Navigating this repository |

### API Concepts

| Diagram | Best For |
|---------|----------|
| Architecture Overview | Understanding FortiManager's role |
| JSON-RPC Flow | Understanding request/response cycle |
| Authentication Methods | Choosing auth method |
| URL Structure | Constructing API endpoints |

### Operations

| Diagram | Best For |
|---------|----------|
| Object Hierarchy | Understanding object relationships |
| CRUD Methods | Learning available operations |
| Policy Installation Workflow | Deploying configuration changes |
| Error Codes | Troubleshooting failures |

---

## File Format

All diagrams are created using [D2](https://d2lang.com/) - a modern diagram scripting language.

```
📂 diagrams/
├── 📊 *.d2     # Source files (editable)
└── 🖼️ *.png    # Generated images (for viewing)
```

### Regenerating Images

To regenerate PNG images from D2 source files:

```bash
# Install D2 (if not already installed)
# macOS: brew install d2
# Linux: curl -fsSL https://d2lang.com/install.sh | sh

# Generate all diagrams
cd diagrams
for f in *.d2; do d2 "$f" "${f%.d2}.png"; done

# Or generate a specific diagram
d2 01-architecture-overview.d2 01-architecture-overview.png
```

---

## See Also

- [Documentation](../docs/README.md) - Conceptual guides
- [Cheatsheets](../cheatsheets/README.md) - Quick references
- [Main README](../README.md) - Project overview
