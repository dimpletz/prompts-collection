# PHP & Magento 2 Development Instructions

## Code Style & Standards
- Follow PSR-1, PSR-4, and PSR-12 coding standards
- Use PHP 8+ features: typed properties, constructor property promotion, match expressions, named arguments
- Apply SOLID principles in all class designs
- Write self-documenting code with clear variable/method names
- Add PHPDoc blocks for all public methods with @param, @return, and @throws tags

## Magento 2 Architecture
- Always use dependency injection via constructor (never use ObjectManager directly)
- Prefer service contracts (interfaces in Api/) for all business logic
- Use plugins (interceptors) instead of class rewrites/preferences
- Implement observers for event-driven functionality
- Use repositories for all data access operations
- Create ViewModels instead of Helper classes for view logic
- Follow the proper module structure under app/code/Vendor/Module/

## Database Operations
- Use declarative schema (db_schema.xml) for all table definitions
- Never write raw SQL without proper escaping/binding
- Use collections with proper filtering and pagination
- Add indexes for frequently queried columns
- Use connection interfaces and avoid direct database access
- Implement data/schema patches for upgrades

## Security Requirements
- Validate and sanitize all user inputs
- Use parameterized queries exclusively (prevent SQL injection)
- Escape all output using $escaper->escapeHtml() and similar methods
- Implement proper ACL resources for admin functionality
- Use FormKey for CSRF protection in all forms
- Validate admin resources in controllers (ADMIN_RESOURCE constant)
- Never expose sensitive data in frontend code or APIs

## Performance Optimization
- Minimize database queries - use collection joins instead of loops
- Implement proper caching with appropriate cache tags
- Use lazy loading proxies for heavy dependencies
- Avoid loading full product/category collections
- Use message queues for heavy/async operations
- Defer non-critical operations to cron jobs
- Enable and use full page cache (FPC)

## Frontend Development
- Use RequireJS for JavaScript modules
- Implement Knockout.js bindings for dynamic UI
- Prefer UI Components over traditional Blocks
- Use mixins to extend core JavaScript
- Follow Magento's LESS/CSS structure
- Optimize images and minimize assets

## API Development
- Define all APIs in Api/ interfaces (service contracts)
- Document with proper @api tags
- Configure in webapi.xml for REST/SOAP
- Implement GraphQL schema in schema.graphqls
- Return proper data transfer objects
- Handle exceptions with appropriate HTTP codes

## Testing
- Write unit tests for all business logic
- Mock all dependencies using PHPUnit mocks
- Achieve minimum 80% code coverage
- Write integration tests for API endpoints
- Test ACL resources and permissions

## Configuration
- Store settings in etc/adminhtml/system.xml
- Retrieve via ScopeConfigInterface
- Use proper scope (global/website/store)
- Define defaults in etc/config.xml
- Never hardcode configuration values

## Error Handling
- Throw specific exceptions (LocalizedException, NoSuchEntityException)
- Log errors using Psr\Log\LoggerInterface
- Provide meaningful error messages
- Never expose stack traces to users
- Catch exceptions at appropriate layers

## Code Comments
- Document complex business logic
- Explain non-obvious decisions
- Add TODO/FIXME for temporary solutions
- Keep comments up-to-date with code
- Avoid obvious comments

## Naming Conventions
- Classes: PascalCase (ProductRepository)
- Methods: camelCase (getProductById)
- Constants: UPPER_SNAKE_CASE (DEFAULT_STORE_ID)
- Private properties: camelCase with $this prefix
- Interfaces: end with "Interface"
- Factories: end with "Factory"

## General Rules
- No code duplication - create reusable methods/classes
- Keep methods short and focused (single responsibility)
- Return early to reduce nesting
- Use strict type comparisons (=== instead of ==)
- Initialize variables before use
- Handle null cases explicitly
- Prefer composition over inheritance
- Make dependencies explicit through constructor injection
