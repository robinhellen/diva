
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
        }
        
        private void CanResolveDecorator()
        {            
            var builder = new ContainerBuilder();
            builder.Register<TestClass>().As<TestInterface>();
            builder.Register<TestDecorator>().AsDecorator<TestInterface>();

            var container = builder.Build();
            try 
            {
                var testClass = container.Resolve<TestInterface>();
                var decorator = testClass as TestDecorator;
                if(decorator == null)
                    fail();
                if(decorator.Inner == null)
                    fail();
                if(!(decorator.Inner is TestClass))
                    fail();
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
    }
}
