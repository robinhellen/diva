using Gee;
using GLib.Test;

using Diva;

namespace Diva.Tests
{
    public class IndexTests : TestFixture
    {
        public IndexTests()
        {
            base("IndexTests");

            add_test("ResolveDirectly", ResolveDirectly);
            add_test("ResolveAsComponent", ResolveAsComponent);
        }

        private void ResolveDirectly()
        {
            var builder = new ContainerBuilder();
            builder.Register<ServiceA>().Keyed<InterfaceA, ServiceEnum>(ServiceEnum.A);
            builder.Register<ServiceB>().Keyed<InterfaceA, ServiceEnum>(ServiceEnum.B);
            var container = builder.Build();
             
            try 
            {
                var resolved = container.ResolveIndexed<InterfaceA, ServiceEnum>();
                var a = resolved[ServiceEnum.A];
                if(a == null)
                {
                    stderr.printf("Unable to create for A\n");
                    fail();
                }
                
                var b = resolved[ServiceEnum.B];
                if(b == null)
                {
                    stderr.printf("Unable to create for B\n");
                    fail();
                }
            } catch (ResolveError e) {Test.message(@"ResolveError: $(e.message)"); fail(); }
        }

        private void ResolveAsComponent()
        {
            var builder = new ContainerBuilder();
            builder.Register<ServiceA>().Keyed<InterfaceA, ServiceEnum>(ServiceEnum.A);
            builder.Register<ServiceB>().Keyed<InterfaceA, ServiceEnum>(ServiceEnum.B);
            builder.Register<RequiresIndex>();
            var container = builder.Build();
             
            try {
                var resolved = container.Resolve<RequiresIndex>();
                var a = resolved.Indexed[ServiceEnum.A];
                if(a == null)
                    fail();
                
                var b = resolved.Indexed[ServiceEnum.B];
                if(b == null)
                    fail();

            } catch (ResolveError e) {
                    stderr.printf("error 3: %s\n", e.message);Test.message(@"ResolveError: $(e.message)"); fail(); }
        }       

        private class ServiceA : Object, InterfaceA {}
        
        private class ServiceB : Object, InterfaceA {}
        
        private enum ServiceEnum {A, B}        
        
        private class RequiresIndex : Object
        {
            static construct
            {
                var cls = (ObjectClass)typeof(RequiresIndex).class_ref();
                SetIndexedInjection<ServiceEnum, InterfaceA>(cls, "Indexed");
            }
            
            public Index<InterfaceA, ServiceEnum> Indexed {construct; get;}
        }
    }
        
        private interface InterfaceA : Object {}
}


