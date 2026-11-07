using System;
using System.Globalization;
using System.Reflection;
using System.Resources;
using System.Text;

internal static class Probe
{
    private static string B64(string s)
    {
        return Convert.ToBase64String(Encoding.UTF8.GetBytes(s == null ? "<null>" : s));
    }

    private static void Main(string[] args)
    {
        var ci = new CultureInfo(args.Length > 3 ? args[3] : "zh-CN");
        System.Threading.Thread.CurrentThread.CurrentUICulture = ci;
        Console.WriteLine("UICULTURE=" + CultureInfo.CurrentUICulture.Name);
        var asm = Assembly.LoadFrom(args[0]);
        var rm = new ResourceManager(args[1], asm);
        try
        {
            var sat = asm.GetSatelliteAssembly(ci);
            Console.WriteLine("SATELLITE=" + sat.Location);
            Console.WriteLine("SAT_RES=" + string.Join(",", sat.GetManifestResourceNames()));
        }
        catch (Exception e)
        {
            Console.WriteLine("SATELLITE_FAIL=" + e.GetType().Name + ": " + e.Message);
        }
        try
        {
            var set = rm.GetResourceSet(ci, true, false);
            Console.WriteLine("SET_PRESENT=" + (set != null));
            if (set != null)
            {
                Console.WriteLine("SET_ASM=" + set.GetType().Assembly.Location);
            }
        }
        catch (Exception e)
        {
            Console.WriteLine("SET_FAIL=" + e.GetType().Name + ": " + e.Message);
        }
        foreach (var k in args[2].Split('|'))
        {
            string v;
            try { v = rm.GetString(k); } catch (Exception e) { v = "ERR:" + e.Message; }
            Console.WriteLine(k + "=" + B64(v));
        }
    }
}
