using GLib.Test;

using Diva;

namespace Diva.Tests
{
    public class ModuleTests : TestFixture
    {
        public ModuleTests()
        {
            base("ModuleTests");
            add_test("SimpleResolve", SimpleResolve);
        }

        private void SimpleResolve()
        {
            var builder = new ContainerBuilder();
            builder.register_module<SimpleModule>();

            var container = builder.build();
            try {
            var testClass = container.resolve<TestClass>();
            if(testClass == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private class SimpleModule : Module
        {
            public override void load(ContainerBuilder builder)
            {
                builder.register<TestClass>();
            }
        }

        private class TestClass : Object, TestInterface {}

        private class TestClassWithDependencies : Object
        {
            public TestClass Dependency {get; construct;}
        }
    }
}
