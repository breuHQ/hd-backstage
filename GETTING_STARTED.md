# Developer Experience - Why?

We believe that a strong shared understanding and terminology around software
and resources leads to a better developer experience, compliance and
knowledge sharing.

## Table of contents

- [Developer Experience - Why?](#developer-experience---why)
  - [Table of contents](#table-of-contents)
  - [Modeling the software](#modeling-the-software)
    - [Component](#component)
    - [API](#api)
    - [Resource](#resource)
  - [Ecosystem Modeling](#ecosystem-modeling)
    - [System](#system)
    - [Domain](#domain)
  - [Getting Started](#getting-started)
    - [Common Components](#common-components)
      - [`name` [required]](#name-required)
      - [`namespace` [optional]](#namespace-optional)
      - [`title` [optional]](#title-optional)
    - [API governance via `catalog-info.yaml`](#api-governance-via-catalog-infoyaml)
      - [Defining the `group` (team)](#defining-the-group-team)
        - [`apiVersion` and `kind` [required]](#apiversion-and-kind-required)
        - [`spec.type` [required]](#spectype-required)
        - [`spec.profile` [optional]](#specprofile-optional)
        - [`spec.parent` [optional]](#specparent-optional)
        - [`spec.children` [required]](#specchildren-required)
        - [`spec.members` [optional]](#specmembers-optional)
      - [Defining the `system`](#defining-the-system)
        - [`apiVersion` and `kind` [required]](#apiversion-and-kind-required-1)
        - [`spec.owner` [required]](#specowner-required)
      - [Defining the `api`](#defining-the-api)
        - [`apiVersion` and `kind` [required]](#apiversion-and-kind-required-2)
        - [`spec.type` [required]](#spectype-required-1)
        - [`spec.lifecycle` [required]](#speclifecycle-required)
        - [`spec.owner` [required]](#specowner-required-1)
        - [`spec.system` [optional]](#specsystem-optional)
        - [`spec.definition` [required]](#specdefinition-required)
      - [Defining the `component`](#defining-the-component)
        - [`apiVersion` and `kind` [required]](#apiversion-and-kind-required-3)
        - [`spec.type` [required]](#spectype-required-2)
        - [`spec.lifecycle` [required]](#speclifecycle-required-1)
        - [`spec.owner` [required]](#specowner-required-2)
        - [`spec.system` [optional]](#specsystem-optional-1)
        - [`spec.subcomponentOf` [optional]](#specsubcomponentof-optional)
        - [`spec.providesApis` [optional]](#specprovidesapis-optional)
        - [`spec.consumesApis` [optional]](#specconsumesapis-optional)
        - [`spec.dependsOn` [optional]](#specdependson-optional)
      - [Putting it all together](#putting-it-all-together)

## Modeling the software

We model software using these three core entities.

- **Components** are individual pieces of software
- **APIs** are the boundaries between different components
- **_Resources_** are physical or virtual infrastructure needed to operate a component.

![Software Model](https://raw.githubusercontent.com/backstage/backstage/master/docs/assets/software-catalog/software-model-core-entities.drawio.svg)

### Component

A component is a piece of software, for example a mobile feature, web site,
backend service or data pipeline (list not exhaustive). A component can be
tracked in source control, or use some existing open source or commercial
software.

A component can implement APIs for other components to consume. In turn it might
consume APIs implemented by other components, or directly depend on components or
resources that are attached to it at runtime.

### API

APIs form an important (maybe the most important) abstraction that allows large
software ecosystems to scale. Thus, APIs are a first class citizen in the
Backstage model and the primary way to discover existing functionality in the
ecosystem.

APIs are implemented by components and form boundaries between components. They
might be defined using an RPC IDL (e.g., Protobuf, GraphQL, ...), a data schema
(e.g., Avro, TFRecord, ...), or as code interfaces. In any case, APIs exposed by
components need to be in a known machine-readable format so we can build further
tooling and analysis on top.

APIs have a visibility: they are either public (making them available for any
other component to consume), restricted (only available to a whitelisted set of
consumers), or private (only available within their system). As public APIs are
going to be the primary way interaction between components, Backstage supports
documenting, indexing and searching all APIs so we can browse them as
developers.

### Resource

Resources are the infrastructure a component needs to operate at runtime, like
BigTable databases, Pub/Sub topics, S3 buckets or CDNs. Modelling them together
with components and systems will better allow us to visualize resource
footprint, and create tooling around them.

## Ecosystem Modeling

A large catalogue of components, APIs and resources can be highly granular and
hard to understand as a whole. It might thus be convenient to further categorize
these entities using the following (optional) concepts:

- **Systems** are a collection of entities that cooperate to perform some
  function
- **Domains** relate entities and systems to part of the business

![Ecosystem Model](https://raw.githubusercontent.com/backstage/backstage/master/docs/assets/software-catalog/software-model-entities.drawio.svg)

### System

With increasing complexity in software, systems form an important abstraction
level to help us reason about software ecosystems. Systems are a useful concept
in that they allow us to ignore the implementation details of a certain
functionality for consumers, while allowing the owning team to make changes as
they see fit (leading to low coupling).

A system, in this sense, is a collection of resources and components that
exposes one or several public APIs. The main benefit of modelling a system is
that it hides its resources and private APIs between the components for any
consumers. This means that as the owner, you can evolve the implementation, in
terms of components and resources, without your consumers being able to notice.
Typically, a system will consist of at most a handful of components (see Domain
for a grouping of systems).

For example, a playlist management system might encapsulate a backend service to
update playlists, a backend service to query them, and a database to store them.
It could expose an RPC API, a daily snapshots dataset, and an event stream of
playlist updates.

### Domain

While systems are the basic level of encapsulation for related entities, it is
often useful to group a collection of systems that share terminology, domain
models, metrics, KPIs, business purpose, or documentation, i.e. they form a
bounded context.

For example, it would make sense if the different systems in the “Payments”
domain would come with some documentation on how to accept payments for a new
product or use-case, share the same entity types in their APIs, and integrate
well with each other. Other domains could be “Content Ingestion”, “Ads” or
“Search”.

## Getting Started

Backstage runs a discovery on gitlab and scans each repo to look for
`catalog-info.yaml` at the root of the repo on the default branch. For example,
if the repo is `https://gitlab.com/hospitality-digital/breu/devex` and the
default branch is configured to be `master` on gitlab, the `backstage` will
look for `catalog-info.yaml` at the master branch.

### Common Components

The `metadata` root field has a number of reserved fields with specific meaning,
described below.

In addition to these, you may add any number of other fields directly under
`metadata`, but be aware that general plugins and tools may not be able to
understand their semantics. See [Extending the model](extending-the-model.md)
for more information.

#### `name` [required]

The name of the entity. This name is both meant for human eyes to recognize the
entity, and for machines and other components to reference the entity (e.g. in
URLs or from other entity specification files).

Names must be unique per kind, within a given namespace (if specified), at any
point in time. This uniqueness constraint is case insensitive. Names may be
reused at a later time, after an entity is deleted from the registry.

Names are required to follow a certain format. Entities that do not follow those
rules will not be accepted for registration in the catalog. The ruleset is
configurable to fit your organization's needs, but the default behavior is as
follows.

- Strings of length at least 1, and at most 63
- Must consist of sequences of `[a-z0-9A-Z]` possibly separated by one of
  `[-_.]`

Example: `visits-tracking-service`, `CircleciBuildsDumpV2_avro_gcs`

#### `namespace` [optional]

Not currently being used, but we might explore this later.

#### `title` [optional]

A display name of the entity, to be presented in user interfaces instead of the
`name` property above, when available.

This field is sometimes useful when the `name` is cumbersome or ends up being
perceived as overly technical. The title generally does not have as stringent
format requirements on it, so it may contain special characters and be more
explanatory. Do keep it very short though, and avoid situations where a title
can be confused with the name of another entity, or where two entities share a
title.

### API governance via `catalog-info.yaml`

The following must be defined in the following order

- group (for teams)
- system (for the aforementioned to be part of).
- api
- component

#### Defining the `group` (team)

The very first thing we need to define is a team that owns the repository. The
structure is as follows

```yaml
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: mejix # required. Must follow [RFC1123](https://datatracker.ietf.org/doc/html/rfc1123)
  title: Mejix # optional.
  description: Breu | Technology for humans # optional.
spec:
  type: team # required. can be anything, like team, business-unit, ops etc.
  profile: # optional. Generally good for display purposes.
    displayName: Mejix Team
    email: mejix@hd.digital
  children: [] # required, but can be an empty array, It contains the `metadata.name` of other groups.
```

A detailed explaination of kind **Group** spec is as follows.

##### `apiVersion` and `kind` [required]

Exactly equal to `backstage.io/v1alpha1` and `Group`, respectively.

##### `spec.type` [required]

The type of group as a string, e.g. `team`. There is currently no enforced set
of values for this field, so it is left up to the adopting organization to
choose a nomenclature that matches their org hierarchy.

Some common values for this field could be:

- `team`
- `business-unit`
- `product-area`
- `root` - as a common virtual root of the hierarchy, if desired

##### `spec.profile` [optional]

Optional profile information about the group, mainly for display purposes. All
fields of this structure are also optional. The email would be a group email of
some form, that the group may wish to be used for contacting them. The picture
is expected to be a URL pointing to an image that's representative of the group,
and that a browser could fetch and render on a group page or similar.

##### `spec.parent` [optional]

The immediate parent group in the hierarchy, if any. Not all groups must have a
parent; the catalog supports multi-root hierarchies. Groups may however not have
more than one parent.

##### `spec.children` [required]

The immediate child groups of this group in the hierarchy (whose `parent` field
points to this group). The list must be present, but may be empty if there are
no child groups. The items are not guaranteed to be ordered in any particular
way.

##### `spec.members` [optional]

The users that are direct members of this group. The items are not guaranteed to
be ordered in any particular way. We do not support this right now.

#### Defining the `system`

The `yaml` for the system looks like follows

```yaml
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: hdpay
spec:
  owner: mejix # defined in groups (can be a user)
```

##### `apiVersion` and `kind` [required]

Exactly equal to `backstage.io/v1alpha1` and `System`, respectively.

##### `spec.owner` [required]

The owner of a system is the singular entity (commonly a team)
that bears ultimate responsibility for the system, and has the authority and
capability to develop and maintain it. They will be the point of contact if
something goes wrong, or if features are to be requested.

#### Defining the `api`

The `api` yaml is ...

```yaml
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: hdpay-rest-api-prod
  description: HD Pay REST API for production
spec:
  type: openapi # type, can be openapi, asyncapi, graphql & grpc
  lifecycle: live # lifecycle, should be `live`, `dev`, `stg` or `acc`
  owner: mejix # the group defined above
  system: hdpay # the system defined above
  definition:
    $text: https://pay.app.hd.digital/api/openapi # the url of the swagger schema is hosted
```

##### `apiVersion` and `kind` [required]

Exactly equal to `backstage.io/v1alpha1` and `API`, respectively.

##### `spec.type` [required]

The type of the API definition as a string, e.g. `openapi`. This field is
required.

The current set of well-known and common values for this field is:

- `openapi` - An API definition in YAML or JSON format based on the
  [OpenAPI](https://swagger.io/specification/) version 2 or version 3 spec.
- `asyncapi` - An API definition based on the
  [AsyncAPI](https://www.asyncapi.com/docs/specifications/latest/) spec.
- `graphql` - An API definition based on
  [GraphQL schemas](https://spec.graphql.org/) for consuming
  [GraphQL](https://graphql.org/) based APIs.
- `grpc` - An API definition based on
  [Protocol Buffers](https://developers.google.com/protocol-buffers) to use with
  [gRPC](https://grpc.io/).

##### `spec.lifecycle` [required]

The current set of well-known and common values for this field is:

- `live` - an established, owned, maintained API
- `acc` - Evironment for acceptance
- `stg` - Staging Environment
- `dev` - The dev environemnt

##### `spec.owner` [required]

The owner of a system is the singular entity (commonly a team)
that bears ultimate responsibility for the system, and has the authority and
capability to develop and maintain it. They will be the point of contact if
something goes wrong, or if features are to be requested.

##### `spec.system` [optional]

System defined above

##### `spec.definition` [required]

the `url` prefixed with `$text` where API definition can be found.

#### Defining the `component`

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: hdpay-api
  title: REST API for HD Pay
  annotations:
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  owner: mejix
  lifecycle: live
  dependsOn: []
  system: hdpay
  providesApis:
    - hdpay-rest-api-prod
    - hdpay-rest-api-dev
    - hdpay-rest-api-stg
    - hdpay-rest-api-acc
```

##### `apiVersion` and `kind` [required]

Exactly equal to `backstage.io/v1alpha1` and `Component`, respectively.

##### `spec.type` [required]

The type of component as a string, e.g. `website`. This field is required.

The current set of well-known and common values for this field is:

- `service` - a backend service, typically exposing an API
- `website` - a website
- `library` - a software library, such as an npm module or a Java library

##### `spec.lifecycle` [required]

The lifecycle state of the component, e.g. `production`. This field is required.

The current set of well-known and common values for this field is:

- `live` - an established, owned, maintained API
- `acc` - Evironment for acceptance
- `stg` - Staging Environment
- `dev` - The dev environemnt

##### `spec.owner` [required]

Defined in the groups spec.

##### `spec.system` [optional]

Defined in `System`

##### `spec.subcomponentOf` [optional]

Reference to another component

##### `spec.providesApis` [optional]

List of APIs it provides. The name should be the one defined in API

##### `spec.consumesApis` [optional]

Which API it consumes. The name should be the one deifned in the API section

##### `spec.dependsOn` [optional]

The names of the components or resources.

#### Putting it all together

After all of this is defined, the final `catalog-info.yaml` will look like below

```yaml
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: hdpay
spec:
  owner: mejix
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: mejix
spec:
  type: team
  profile:
    displayName: Mejix
    email: info@Mejix.com
  children: []
---
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: hdpay-rest-api-prod
  description: HD Pay REST API for production
spec:
  type: openapi
  lifecycle: live
  owner: mejix
  system: hdpay
  definition:
    $text: https://pay.app.hd.digital/api/openapi
---
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: hdpay-rest-api-dev
  description: HD Pay REST API for development
spec:
  type: openapi
  lifecycle: dev
  owner: mejix
  system: hdpay
  definition:
    $text: https://pay.dev.app.hd.digital/api/openapi
---
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: hdpay-rest-api-stg
  description: HD Pay REST API for staging
spec:
  type: openapi
  lifecycle: stage
  owner: mejix
  system: hdpay
  definition:
    $text: https://pay.dev.app.hd.digital/api/openapi
---
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: hdpay-rest-api-acc
  description: HD Pay REST API for acceptance
spec:
  type: openapi
  lifecycle: acceptance
  owner: mejix
  system: hdpay
  definition:
    $text: https://pay.acc.app.hd.digital/api/openapi
```
