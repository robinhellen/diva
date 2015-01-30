using GLib.Test;

using Diva;

namespace Diva.Tests
{
    static int main(string[] args)
    {
        Test.init(ref args);
        var rootSuite = TestSuite.get_root();

        rootSuite.add_suite(new SimpleTest().get_suite());
        rootSuite.add_suite(new CreationStrategyTests().get_suite());

        Test.run();
        return 0;
    }

    public class SimpleTest : TestFixture
    {
        public SimpleTest()
        {
            base("SimpleTest");
            add_test("SimpleResolve", SimpleResolve);
            add_test("ResolveTypeAuto", ResolveTypeAuto);
            add_test("ResolveTypeWithDependency", ResolveTypeWithDependency);
            add_test("ResolveByInterface", ResolveByInterface);
        }

        private void SimpleResolve()
        {
            var builder = new ContainerBuilder();
            builder.Register<TestClass>(_ => new TestClass());

            var container = builder.Build();
            try {
            var testClass = container.Resolve<TestClass>();
            if(testClass == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void ResolveTypeAuto()
        {
            var builder = new ContainerBuilder();
            builder.Register<TestClass>();

            var container = builder.Build();
            try {
            var testClass = container.Resolve<TestClass>();
            if(testClass == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void ResolveTypeWithDependency()
        {
            var builder = new ContainerBuilder();
            builder.Register<TestClass>();
            builder.Register<TestClassWithDependencies>();

            var container = builder.Build();
            try {
            var testClassWithDependencies = container.Resolve<TestClassWithDependencies>();
            if(testClassWithDependencies == null)
                fail();
            if(testClassWithDependencies.Dependency == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void ResolveByInterface()
        {
            var builder = new ContainerBuilder();
            builder.Register<TestClass>().As<TestInterface>();

            var container = builder.Build();
            try {
            var testInterface = container.Resolve<TestInterface>();
            if(testInterface == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }


        private class TestClass : Object, TestInterface {}

        private class TestClassWithDependencies : Object
        {
            public TestClass Dependency {get; construct;}
        }
    }

    private interface TestInterface : Object {}
}
