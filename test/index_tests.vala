using Gee;
using GLib.Test;

using Diva;

namespace Diva.Tests
{
    public class IndexTests : TestFixture
    {
        public IndexTests()
        {
            base("IndexTests");

            add_test("ResolveDirectly", ResolveDirectly);
            add_test("ResolveAsComponent", ResolveAsComponent);
            add_test("CanIndexOnStrings", CanIndexOnStrings);
            add_test("CanIndexComponentsOnStrings", CanIndexComponentsOnStrings);
        }

        private void ResolveDirectly()
        {
            var builder = new ContainerBuilder();
            builder.register<ServiceA>().keyed<InterfaceA, ServiceEnum>(ServiceEnum.A);
            builder.register<ServiceB>().keyed<InterfaceA, ServiceEnum>(ServiceEnum.B);
            var container = builder.build();

            try
            {
                var resolved = container.resolve_indexed<InterfaceA, ServiceEnum>();
                var a = resolved[ServiceEnum.A];
                if(a == null)
                {
                    stderr.printf("Unable to create for A\n");
                    fail();
                }

                var b = resolved[ServiceEnum.B];
                if(b == null)
                {
                    stderr.printf("Unable to create for B\n");
                    fail();
                }
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void ResolveAsComponent()
        {
            var builder = new ContainerBuilder();
            builder.register<ServiceA>().keyed<InterfaceA, ServiceEnum>(ServiceEnum.A);
            builder.register<ServiceB>().keyed<InterfaceA, ServiceEnum>(ServiceEnum.B);
            builder.register<RequiresIndex>();
            var container = builder.build();

            try {
                var resolved = container.resolve<RequiresIndex>();
                var a = resolved.Indexed[ServiceEnum.A];
                if(a == null)
                    fail();

                var b = resolved.Indexed[ServiceEnum.B];
                if(b == null)
                    fail();

            } catch (ResolveError e) {
                    stderr.printf("error 3: %s\n", e.message);Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void CanIndexOnStrings()
        {
            var builder = new ContainerBuilder();
            builder.register<ServiceA>().keyed<InterfaceA, string>("A");
            builder.register<ServiceB>().keyed<InterfaceA, string>("B");
            var container = builder.build();

            try
            {
                var resolved = container.resolve_indexed<InterfaceA, string>();
                var a = resolved["A"];
                if(a == null)
                {
                    stderr.printf("Unable to create for A\n");
                    fail();
                }

                var b = resolved["B"];
                if(b == null)
                {
                    stderr.printf("Unable to create for B\n");
                    fail();
                }
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void CanIndexComponentsOnStrings()
        {
            var builder = new ContainerBuilder();
            builder.register<ServiceA>().keyed<InterfaceA, string>("A");
            builder.register<ServiceB>().keyed<InterfaceA, string>("B");
            builder.register<RequiresStringIndex>();
            var container = builder.build();

            try {
                var resolved = container.resolve<RequiresStringIndex>();
                var a = resolved.Indexed["A"];
                if(a == null)
                    fail();

                var b = resolved.Indexed["B"];
                if(b == null)
                    fail();

            } catch (ResolveError e) {
                    stderr.printf("error 3: %s\n", e.message);Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private class ServiceA : Object, InterfaceA {}

        private class ServiceB : Object, InterfaceA {}

        private enum ServiceEnum {A, B}

        private class RequiresIndex : Object
        {
            static construct
            {
                var cls = (ObjectClass)typeof(RequiresIndex).class_ref();
                set_indexed_injection<ServiceEnum, InterfaceA>(cls, "Indexed");
            }

            public Index<InterfaceA, ServiceEnum> Indexed {construct; get;}
        }

        private class RequiresStringIndex : Object
        {
            static construct
            {
                var cls = (ObjectClass)typeof(RequiresStringIndex).class_ref();
                set_indexed_injection<string, InterfaceA>(cls, "Indexed");
            }

            public Index<InterfaceA, string> Indexed {construct; get;}
        }
    }

        private interface InterfaceA : Object {}
}


