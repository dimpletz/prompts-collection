### Magento 2-Specific Review Categories

**Module Structure**
- [MAJOR] `registration.php` present and uses correct `ComponentRegistrar::MODULE` type
- [MAJOR] `module.xml` declares correct `setup_version` (if used) or uses declarative schema; dependencies declared via `<sequence>`
- [MAJOR] No circular module dependencies
- [MAJOR] Area-appropriate code: frontend-only blocks not loaded in adminhtml or crontab areas

**Dependency Injection (di.xml)**
- [MAJOR] Constructor dependencies declared with interface types; not concrete class types (violates DIP)
- [MINOR] Preferences justified; plugins preferred for extending behaviour without replacing it
- [MINOR] Virtual types used to reuse existing classes with different constructor arguments instead of creating trivial subclasses
- [MINOR] Proxy classes used for heavy optional dependencies that are not always needed
- [MAJOR] `ObjectManager::getInstance()` not used directly in business logic (only acceptable in factories, proxies, and test bootstraps)
- [MAJOR] `\Magento\Framework\App\ObjectManager` not injected as a constructor dependency

**Plugins (Interceptors)**
- [MINOR] Plugin class names follow convention: `<Vendor>\<Module>\Plugin\<TargetClass>`
- [MINOR] `around` plugins used only when `before` or `after` is insufficient (around adds overhead for every call)
- [CRITICAL] `around` plugins call `$proceed()` exactly once on the non-exception path; not missing the call
- [CRITICAL] Plugin methods have correct signatures: `before` returns array or null; `after` returns modified result; `around` calls `$proceed`
- [MAJOR] Plugins not applied to final methods, constructors, static methods, or non-public methods
- [MAJOR] Plugin declarations in di.xml have correct `type` pointing to the target class/interface

**Observers / Events**
- [MAJOR] Observer classes implement `\Magento\Framework\Event\ObserverInterface` with `execute(Observer $observer)` method
- [MAJOR] `events.xml` declares correct area (global, frontend, adminhtml, etc.); not `global` for area-specific events
- [MAJOR] Observers do not perform heavy synchronous operations that would block the request (use async queues instead)
- [MAJOR] Event data not modified via `$event->getData()` mutation unless the event explicitly supports it

**Service Contracts and Repositories**
- [MAJOR] Repository interfaces extend `\Magento\Framework\Api\SearchResultsInterface` for list operations
- [MAJOR] `SearchCriteria` used for all list/filter operations; not custom `getCollection()->addFieldToFilter()` calls in service layer
- [MINOR] Data interfaces (DTOs) extend `\Magento\Framework\Api\ExtensibleDataInterface` or `\Magento\Framework\Api\CustomAttributesDataInterface` when extension attributes are needed
- [MAJOR] Repositories do not leak `ResourceModel` or `Collection` objects through their public API
- [MAJOR] `save()` and `delete()` in repository interfaces handle `CouldNotSaveException` / `CouldNotDeleteException`

**Layout XML and Blocks**
- [MINOR] Block classes extend `\Magento\Framework\View\Element\Template` (or appropriate parent); not directly extending `AbstractBlock` for template-rendering blocks
- [MINOR] `getChildHtml()` used to include child blocks; not instantiating blocks in PHP code
- [MAJOR] No business logic in blocks; data retrieval via injected repositories or view models
- [MINOR] View models preferred over blocks for data provisioning (no `getLayout()->createBlock()` in templates)
- [MAJOR] Layout handles scoped correctly; not adding global handles that affect all pages unintentionally
- [MINOR] `<referenceBlock>` and `<referenceContainer>` with `remove="true"` used to remove blocks; not overriding parent templates entirely to remove a block

**PHTML Templates**
- [CRITICAL] All output escaped per context: HTML content → `escapeHtml()`, URLs → `escapeUrl()`, HTML attribute values → `escapeHtmlAttr()`, JavaScript strings → `escapeJs()`
- [CRITICAL] No `echo $_GET['param']`, `echo $this->getRequest()->getParam('x')` without escaping
- [MAJOR] PHP logic in templates minimal: only conditional rendering and loop iteration; no data fetching, ORM calls, or business logic
- [MINOR] `$block->getData('key')` used to access block data; not `$this->getKey()` magic getters in new code (deprecated pattern)
- [MINOR] i18n: all user-visible strings wrapped in `__('...')` or `$block->escapeHtml(__('...'))`

**Declarative Schema and Upgrades**
- [MAJOR] `db_schema.xml` used for schema changes (Magento 2.3+); not `InstallSchema.php` / `UpgradeSchema.php` (deprecated)
- [MAJOR] `db_schema_whitelist.json` updated when columns/indexes removed to ensure reversibility
- [MAJOR] Data patches (`DataPatchInterface`) used for data migrations; `InstallData.php` / `UpgradeData.php` not used in new modules