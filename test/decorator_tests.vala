
using GLib.Test;

using Diva;

namespace Diva.Tests
{
    public class DecoratorTests : TestFixture
    {
        public DecoratorTests()
        {
            base("DecoratorTests");
            add_test("CanResolveDecorator", CanResolveDecorator);
            add_test("LazyDependenciesAreDecorated", LazyDependenciesAreDecorated);
        }

        private void CanResolveDecorator()
        {
            var builder = new ContainerBuilder();
            builder.register<TestClass>().as<TestInterface>();
            builder.register<TestDecorator>().as_decorator<TestInterface>();

            var container = builder.build();
            try
            {
                var testClass = container.resolve<TestInterface>();
                var decorator = testClass as TestDecorator;
                if(decorator == null)
                    {fail(); return;}
                if(decorator.Inner == null)
                    {fail(); return;}
                if(!(decorator.Inner is TestClass))
                    {fail(); return;}
            }
            catch (ResolveError e)
            {
                Test.message(@"ResolveError: $(e.message)");
                fail();
            }
        }
        
        private void LazyDependenciesAreDecorated()
        {
            var builder = new ContainerBuilder();
            builder.register<WithLazyDecorator>();
            builder.register<TestClass>().as<TestInterface>();
            builder.register<TestDecorator>().as_decorator<TestInterface>();

            var container = builder.build();
            try
            {
                var test_class = container.resolve<WithLazyDecorator>();
                var i = test_class.test_interface;
                var decorator = i as TestDecorator;
                if(decorator == null)
                    {fail(); return;}
                if(decorator.Inner == null)
                    {fail(); return;}
                if(!(decorator.Inner is TestClass))
                    {fail(); return;}
            }
            catch (ResolveError e)
            {
                Test.message(@"ResolveError: $(e.message)");
                fail();
            }            
        }

        private class TestClass : Object, TestInterface
        {

        }

        private class TestDecorator : Object, TestInterface
        {
            public TestInterface Inner {construct; get;}
        }
        
        private class WithLazyDecorator : Object
        {
            public TestInterface test_interface {construct; get;}
        }
    }
}
