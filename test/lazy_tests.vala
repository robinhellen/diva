using Gee;
using GLib.Test;

using Diva;

namespace Diva.Tests
{
    public class LazyTests : TestFixture
    {
        public LazyTests()
        {
            base("LazyTests");

            add_test("ResolveDirectly", ResolveDirectly);
            add_test("ResolveAsComponent", ResolveAsComponent);
            add_test("UnresolvableLazysErrorEarly", UnresolvableLazysErrorEarly);
        }

        private void ResolveDirectly()
        {
            InstantiationCounter.ResetCount();

            var builder = new ContainerBuilder();
            builder.register<InstantiationCounter>();
            var container = builder.build();

            try {
                Lazy<InstantiationCounter> resolved = container.resolve_lazy<InstantiationCounter>();

                if(InstantiationCounter.InstantiationCount != 0)
                {
                    Test.message(@"Should not have created the object yet. $(InstantiationCounter.InstantiationCount).");
                    fail();
                }

                var counter = resolved.value;
                counter = resolved.value;
                if(InstantiationCounter.InstantiationCount != 1)
                {
                    fail();
                }

            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void ResolveAsComponent()
        {
            InstantiationCounter.ResetCount();

            var builder = new ContainerBuilder();
            builder.register<RequiresLazy>();
            builder.register<InstantiationCounter>();
            var container = builder.build();

            try {
                var resolved = container.resolve<RequiresLazy>();

                if(InstantiationCounter.InstantiationCount != 0)
                {
                    Test.message(@"Should not have created the object yet. $(InstantiationCounter.InstantiationCount).");
                    fail();
                }

                resolved.UseLazy();

                if(InstantiationCounter.InstantiationCount != 1)
                {
                    Test.message(@"Should have created the counter once, actually: $(InstantiationCounter.InstantiationCount).");
                    fail();
                }

            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }
        
        private void UnresolvableLazysErrorEarly()
        {            
            var builder = new ContainerBuilder();
            builder.register<RequiresLazy>();
            var container = builder.build();

            try {
                container.resolve_lazy<RequiresLazy>();
                
                Test.message(@"Should not have been able to create a lazy when dependencies are not available.");
                fail();
                

            } catch (ResolveError e) {}
        }

        private class InstantiationCounter : Object
        {
            public static int InstantiationCount = 0;

            public static void ResetCount() {InstantiationCount = 0;}

            construct {InstantiationCount++;}
        }

        private class RequiresLazy : Object
        {
            static construct
            {
                var cls = (ObjectClass)typeof(RequiresLazy).class_ref();
                set_lazy_injection<InstantiationCounter>(cls, "Lazy");
            }

            public Lazy<InstantiationCounter> Lazy {construct; private get;}

            public void UseLazy()
            {
                var c = Lazy.value;
                c = Lazy.value;
            }
        }
    }
}

