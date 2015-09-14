
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
            builder.register<TestClass>()
                    .ignore_property("ignore-this");

            var container = builder.build();
            try {
            var testClass = container.resolve<TestClass>();
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
