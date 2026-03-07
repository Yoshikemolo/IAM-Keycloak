# Client Application Examples

This folder contains working, self-contained example applications demonstrating how to integrate with the Keycloak IAM platform across multiple programming languages and frameworks.

Every example follows Clean Architecture principles, includes comprehensive documentation comments (JavaDoc, TSDoc, docstrings, XML doc), and is designed to be used as a production-ready starting point.

## Backend Services (Resource Servers)

Backend services validate incoming tokens, enforce role-based access control, and integrate with Open Policy Agent for fine-grained authorization.

| Folder | Framework | Language | Documentation |
|--------|-----------|----------|---------------|
| [java/spring-boot](java/spring-boot/) | Spring Boot 3.4 | Java 17 | [Guide](../doc/14-01-spring-boot.md) |
| [java/quarkus](java/quarkus/) | Quarkus 3.17 | Java 17 | [Guide](../doc/14-10-quarkus.md) |
| [dotnet](dotnet/) | ASP.NET Core | C# / .NET 9 | [Guide](../doc/14-02-dotnet.md) |
| [node/nestjs](node/nestjs/) | NestJS 10 | TypeScript | [Guide](../doc/14-03-nestjs.md) |
| [node/express](node/express/) | Express | Node.js 22 | [Guide](../doc/14-04-express.md) |
| [python/fastapi](python/fastapi/) | FastAPI | Python 3.12 | [Guide](../doc/14-05-python-fastapi.md) |

## Frontend Applications (Relying Parties)

Frontend applications handle the user-facing authentication flow using OpenID Connect with Authorization Code + PKCE. All frontends include:

- Internationalization (i18n) with multi-language support
- Dark and light theme support via CSS custom properties
- Minimalist, modern UI without heavy component libraries
- Role-based component rendering

| Folder | Framework | Language | Documentation |
|--------|-----------|----------|---------------|
| [frontend/nextjs](frontend/nextjs/) | Next.js 15 | TypeScript | [Guide](../doc/14-06-nextjs.md) |
| [frontend/angular](frontend/angular/) | Angular 19 | TypeScript | [Guide](../doc/14-07-angular.md) |
| [frontend/react](frontend/react/) | React 19 | TypeScript | [Guide](../doc/14-08-react.md) |
| [frontend/vue](frontend/vue/) | Vue 3.5 | TypeScript | [Guide](../doc/14-09-vue.md) |

## Running the Examples

Each example includes its own README with specific setup instructions. The general workflow is:

1. Start Keycloak locally using the Docker Compose file in `../infra/docker/`
2. Import the tenant realm from `../keycloak/realms/`
3. Navigate to the example folder and follow its README
4. Use the frontend application to authenticate and test the backend APIs

## Related Documentation

- [Client Applications Hub](../doc/14-client-applications.md)
- [Architecture Overview](../doc/01-target-architecture.md)
- [Authentication and Authorization](../doc/08-authentication-authorization.md)
