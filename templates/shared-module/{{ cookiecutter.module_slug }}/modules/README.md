# Modules

Child modules used only by this shared module, each in its own subdirectory
(e.g. `modules/<child-name>/`). Child modules are local, not independently
version-controlled, and exist to provide minor abstractions or reduce
duplication within this module — they aren't meant to be reused outside of
it. If logic needs to be reused across shared modules, promote it to its own
shared module instead.

Delete this file once a real child module has been added; delete this
directory entirely if this module never needs one.
