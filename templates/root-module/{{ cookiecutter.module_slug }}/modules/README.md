# Modules

Local child modules used only by this root configuration, each in its own
subdirectory (e.g. `modules/<child-name>/`).

Child modules are local abstractions that reduce duplication or complexity
within this configuration — they aren't meant to be reused outside of it. If
logic needs to be reused across configurations, promote it to a shared module
in the [shared-modules](https://github.com/JoshSLawrence/shared-modules)
repository instead.

Delete this file once a real child module has been added; delete this
directory entirely if this configuration never needs one.
