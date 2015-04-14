using GLib.Test;

using Diva;

namespace Diva.Tests
{
    public class ErrorTests : TestFixture
    {
        public ErrorTests()
        {
            base("ErrorTests");
            add_test("ErrorsOnPrimitiveCycle", PrimitiveCycle);
        }
        
        private void PrimitiveCycle()
        {            
            var builder = new ContainerBuilder();
            builder.Register<TestClass>();

            var container = builder.Build();
            try {
                var testClass = container.Resolve<TestClass>();
                fail();
            } 
            catch (ResolveError e) 
            {
                Test.message(@"ResolveError: $(e.message)"); 
            }
        }
        
        private class TestClass : Object
        {
            public TestClass Recursive {get; construct;}
        }
    }
}
