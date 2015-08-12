
using GLib.Test;

using Diva;

namespace Diva.Tests
{
    public class PropertyTests : TestFixture
    {
        public PropertyTests()
        {
            base("PropertyTests");
            add_test("IgnoredProperty", IgnoredProperty);
        }

        private void IgnoredProperty()
        {
            var builder = new ContainerBuilder();
            builder.Register<TestClass>()
                    .ignore_property("ignore-this");

            var container = builder.Build();
            try {
            var testClass = container.Resolve<TestClass>();
            if(testClass == null)
                fail();
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private class TestClass : Object
        {
            public int ignore_this {get; construct;}
        }
    }
}
