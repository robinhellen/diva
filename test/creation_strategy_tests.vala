using GLib.Test;

using Diva;

namespace Diva.Tests
{
    public class CreationStrategyTests : TestFixture
    {
        public CreationStrategyTests()
        {
            base("CreationStrategyTests");

            add_test("PerDependencyDefault", PerDependencyDefault);
            add_test("SingleInstance", SingleInstance);
        }

        private void PerDependencyDefault()
        {
            InstantiationCounter.ResetCount();

            var builder = new ContainerBuilder();
            builder.register<InstantiationCounter>();
            var container = builder.build();
            try {
                var counter = container.resolve<InstantiationCounter>();
                counter = container.resolve<InstantiationCounter>();


                if(InstantiationCounter.InstantiationCount != 2)
                    fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void SingleInstance()
        {
            InstantiationCounter.ResetCount();

            var builder = new ContainerBuilder();
            builder.register<InstantiationCounter>().single_instance();
            var container = builder.build();
            try {
                var counter = container.resolve<InstantiationCounter>();
                counter = container.resolve<InstantiationCounter>();


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
