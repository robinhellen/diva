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
            builder.RegisterModule<SimpleModule>();

            var container = builder.Build();
            try {
            var testClass = container.Resolve<TestClass>();
            if(testClass == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private class SimpleModule : Module
        {
            public override void Load(ContainerBuilder builder)
            {
                builder.Register<TestClass>();
            }
        }

        private class TestClass : Object, TestInterface {}

        private class TestClassWithDependencies : Object
        {
            public TestClass Dependency {get; construct;}
        }
    }
}
