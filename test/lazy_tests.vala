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
        }

        private void ResolveDirectly()
        {
            InstantiationCounter.ResetCount();

            var builder = new ContainerBuilder();
            builder.Register<InstantiationCounter>();
            var container = builder.Build();
             
            try {
                Lazy<InstantiationCounter> resolved = container.ResolveLazy<InstantiationCounter>();
            
                if(InstantiationCounter.InstantiationCount != 0)
                {
                    Test.message(@"Should not have created the object yet. $(InstantiationCounter.InstantiationCount).");
                    fail();
                }
               
                var counter = resolved.value;
                if(InstantiationCounter.InstantiationCount != 1)
                {
                    fail();
                }

            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void SingleInstance()
        {
            InstantiationCounter.ResetCount();

            var builder = new ContainerBuilder();
            builder.Register<InstantiationCounter>().SingleInstance();
            var container = builder.Build();
            try {
                var counter = container.Resolve<InstantiationCounter>();
                counter = container.Resolve<InstantiationCounter>();


                if(InstantiationCounter.InstantiationCount != 1)
                    fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private class InstantiationCounter : Object
        {
            public static int InstantiationCount = 0;

            public static void ResetCount() {InstantiationCount = 0;}

            construct {InstantiationCount++;}
        }
    }
}

