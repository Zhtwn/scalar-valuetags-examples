# Value Magic examples

This repository contains examples of modules that can be implemented
using the Viral Value Magic introduced in [this PPC](https://github.com/leonerd/Perl-PPCs/blob/ppc-magic-v2/ppcs/ppc0036-viral-value-magic.md).

All of these examples use the API provided by [`Scalar::ValueTags`](https://github.com/Zhtwn/Scalar-ValueTags).

## DataTracking

Provides the ability to attach metadata to data values when they are received
from any external system, propagate that metadata every time the data values
are used within the system's dataflow, and report that combined source metadata
every time a data value is sent to an external system.

This provides the core infrastructure for a data lineage system that tracks
the flow of the data values in realtime through the system, for reporting in
formats such as OpenLineage.

## SecurityLabeling

Provides the ability to attach security labels to data values, propagate the
highest-level label every time the data values are used within the system's
dataflow, and apply data access controls to data usage based on the required
security label.

## TaggedTaint

Provides an ability similar to the builtin Perl `taint`, but allowing multiple
taint tags to be set on each data value. Unlike the `taint` builtin, this
module does not automatically apply the access control at predetermined Perl
operations. Instead, it allows the access control to be applied by the client
at any time.
than 

