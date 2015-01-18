using GLib.Test;

using Diva;

namespace Ldraw.Tests
{
    static int main(string[] args)
    {
        Test.init(ref args);
        var rootSuite = TestSuite.get_root();

        rootSuite.add_suite(new SimpleTest().get_suite());

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
        }

        private void SimpleResolve()
        {
            var builder = new ContainerBuilder();
            builder.Register<TestClass>(_ => new TestClass());

            var container = builder.Build();
            var testClass = container.Resolve<TestClass>();
            if(testClass == null)
                fail();
        }

        private void ResolveTypeAuto()
        {
            var builder = new ContainerBuilder();
            builder.Register<TestClass>();

            var container = builder.Build();
            var testClass = container.Resolve<TestClass>();
            if(testClass == null)
                fail();

        }

        private void ResolveTypeWithDependency()
        {
            var builder = new ContainerBuilder();
            builder.Register<TestClass>();
            builder.Register<TestClassWithDependencies>();

            var container = builder.Build();
            var testClassWithDependencies = container.Resolve<TestClassWithDependencies>();
            if(testClassWithDependencies == null)
                fail();
            if(testClassWithDependencies.Dependency == null)
                fail();

        }

        private class TestClass : Object {}

        private class TestClassWithDependencies : Object
        {
            public TestClass Dependency {get; construct;}
        }
    }
}
