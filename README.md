# diva

Diva is a dependency injection framework for GLib-based applications.
Dependencies between classes can be managed so that apllications stay maintainable as they grow.
Diva is designed to be used with the Vala programming language

### Using Diva

#### Registering components

Components that provide services are registered with a ```ContainerBuilder```

    var builder = new ContainerBuilder();
Diva can use a delegate, a type, or an exising instance:
    builder.Register<FooService>(ctx => new FooComponent());
    builder.Register<FooComponent>().As<FooService>();
    builder.RegisterInstance<FooService>(new FooComponent());
calling ```Build()``` creates a container
    var container = builder.Build();
instances of a service can then be requested using Resolve<T>()
    var fooService = container.Resolve<FooService>();

#### Expressing dependencies

Dependencies are expressed as public properties of the component
    public class FooComponent : Object, FooService
    {
        public BarService bar { construct; private get; }
    }
When constructing a FooComponent, Diva will look for a component that provides BarService and
set the property bar to it.
