# Dynamics 365 Finance & Operations Custom Feature Management

## 📌 Overview
The **DAX Custom Feature Management** framework provides a structured way to manage custom features in **Dynamics 365 Finance & Operations (D365FO)**.  
It allows developers to enable/disable features either **globally (cross-company)** or **per company**, ensuring flexibility and control over new customizations.

This solution is designed and maintained by **DAXONET GROUP SDN BHD**.

---

## ✨ Features
- Core model for managing custom features in D365FO.
- Interfaces for **cross-company** and **per-company** feature toggling.
- Easy-to-use implementation pattern (singleton instance).
- Integration with **forms, menus, and event handlers**.
- Support for enabling/disabling customizations dynamically.

---

## ⚙️ Installation
> 📌 *Note: Installation details will be updated in future versions.*

1. Import the model into your D365FO development environment.
2. Synchronize the database.
3. Build the project.

---

## 🚀 Implementation

### Step 1: Create a Custom Feature Class
Implement one of the provided interfaces:
- `DAXCustomIFeature` → Feature enabled cross-company.
- `DAXCustomIFeatureCompany` → Feature enabled per company.

Example:
```xpp
internal final class MyCustomFeature implements DAXCustomIFeature
{
    private static MyCustomFeature instance;

    private void new() { }

    private static void typeNew()
    {
        instance = new MyCustomFeature();
    }

    public static MyCustomFeature instance()
    {
        return MyCustomFeature::instance;
    }

    [Hookable(false)]
    public str featureNumber() { return 'CR123'; }

    [Hookable(false)]
    public str displayName() { return 'My Custom Feature'; }

    [Hookable(false)]
    public int module()
    {
        return FeatureModuleV0::InventoryAndWarehouseManagement;
    }

    [Hookable(false)]
    public boolean isEnabled()
    {
        return DAXCustomFeatureStateProvider::isFeatureEnabled(
            MyCustomFeature::instance()
        );
    }
}
```

### Step 2: Add Handlers and Extensions
Attach feature toggles in forms, menus, or methods:
```xpp
[FormEventHandler(formStr(InventLocation), FormEventType::Initialized)]
public static void InventLocation_OnInitialized(xFormRun sender, FormEventArgs e)
{
    boolean isEnabled = MyCustomFeature::instance().isEnabled();
    sender.dataSource('InventLocation').object(fieldNum(InventLocation, MyField)).visible(isEnabled);
}
```

---

## ⚡ Quick Start Example

Here’s a minimal working implementation you can copy-paste to test the framework:

```xpp
// Feature class
internal final class DemoFeature implements DAXCustomIFeature
{
    private static DemoFeature instance;

    private void new() { }
    private static void typeNew() { instance = new DemoFeature(); }

    public static DemoFeature instance()
    {
        return DemoFeature::instance;
    }

    [Hookable(false)]
    public str featureNumber() { return 'DF001'; }

    [Hookable(false)]
    public str displayName() { return 'Demo Feature Toggle'; }

    [Hookable(false)]
    public int module()
    {
        return FeatureModuleV0::SystemAdministration;
    }

    [Hookable(false)]
    public boolean isEnabled()
    {
        return DAXCustomFeatureStateProvider::isFeatureEnabled(
            DemoFeature::instance()
        );
    }
}

// sample form handler
[FormEventHandler(formStr(SysUserInfo), FormEventType::Initialized)]
public static void SysUserInfo_OnInitialized(xFormRun sender, FormEventArgs e)
{
    boolean enabled = DemoFeature::instance().isEnabled();
    sender.design().controlName('UserGroup').visible(enabled);
}

//Sample for menu handler
[SubscribesTo(classstr(SysMenuNavigationObjectFactory), staticdelegatestr(SysMenuNavigationObjectFactory, checkAddSubMenuDelegate))]
public static void menuItemVisibilityHandler(SysDictMenu _rootMenu, SysDictMenu _subMenu, SysBoxedBoolean _subMenuVisibility)
{
	if (_subMenu.isMenuItem())
	{
		var metaElement = _subMenu.GetMenuItemMetaElement();
		if (metaElement != null)
		{
			if (metaElement.Name == menuItemDisplayStr(DemoSetup))
			{
				_subMenuVisibility.value = DemoFeature::isEnabled();
			}
		}
	}
	else if (_subMenu.isTileReference())
	{
		var metaElement = _subMenu.getTileMetaElement();
		if (metaElement != null)
		{
			if (metaElement.Name == tileStr(DemoWorkspace))
			{
				_subMenuVisibility.value = DemoFeature::isEnabled();
			}
		}
	}
}
```

👉 Once deployed, navigate to **System administration > Setup > Custom feature management** and enable `Demo Feature Toggle`.  
You should see the **User Group** control in `SysUserInfo` form toggle visibility based on the feature’s status.

---

## 🧭 Architecture Diagram

```mermaid
flowchart LR
  A[Feature class implements<br/>DAXCustomIFeature / DAXCustomIFeatureCompany] --> B[Singleton instance<br/>+ metadata: featureNumber, displayName, module]
  B --> C[isEnabled() calls<br/>DAXCustomFeatureStateProvider::isFeatureEnabled(instance)]
  C -->|true/false| D[Handlers & Extensions<br/>(forms, menus, methods) show/hide or execute]
  E[Setup runner<br/>DAXCustomFeatureManagementSetup] --> F[Feature records<br/>(Dev VM manual init)]
  F --> C
  G[Custom feature management pages<br/>System administration > Setup] --> F
```

---

## 🔑 Enabling Features
On **development VMs**, records are not auto-created.  
Run the following URL to update setup:

```
https://<host>/?cmp=dat&mi=SysClassRunner&cls=DAXCustomFeatureManagementSetup
```

Navigation in D365FO:
- **System administration > Setup > Custom feature management**
- **System administration > Setup > Custom feature management by company**

> Source: Technical guideline details on interfaces, sample patterns, and enable steps.【8†source】

---

## 📜 Versioning
- **v1.0 (1 March 2023)** – Initial release by LS Mark.

