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
        rootSuite.add_suite(new LazyTests().get_suite());
        rootSuite.add_suite(new IndexTests().get_suite());
        rootSuite.add_suite(new PropertyTests().get_suite());
        rootSuite.add_suite(new ErrorTests().get_suite());
        rootSuite.add_suite(new DecoratorTests().get_suite());
        rootSuite.add_suite(new CollectionTests().get_suite());
        rootSuite.add_suite(new ModuleTests().get_suite());
        rootSuite.add_suite(new RegistrationErrors().get_suite());

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
            builder.register<TestClass>(_ => new TestClass());

            var container = builder.build();
            try {
            var testClass = container.resolve<TestClass>();
            if(testClass == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void ResolveTypeAuto()
        {
            var builder = new ContainerBuilder();
            builder.register<TestClass>();

            var container = builder.build();
            try {
            var testClass = container.resolve<TestClass>();
            if(testClass == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void ResolveTypeWithDependency()
        {
            var builder = new ContainerBuilder();
            builder.register<TestClass>();
            builder.register<TestClassWithDependencies>();

            var container = builder.build();
            try {
            var testClassWithDependencies = container.resolve<TestClassWithDependencies>();
            if(testClassWithDependencies == null)
                fail();
            if(testClassWithDependencies.Dependency == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void ResolveByInterface()
        {
            var builder = new ContainerBuilder();
            builder.register<TestClass>().as<TestInterface>();

            var container = builder.build();
            try {
            var testInterface = container.resolve<TestInterface>();
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
