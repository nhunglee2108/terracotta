package terracottawithgroovy

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

class Activator implements BundleActivator{

	@Override
	public void start(BundleContext arg0) throws Exception {
		println "Hello! This is groovy Activator. NO Setting ClassLoader, default config terracotta, export package"
		ClassLoader originalClassLoader = Thread.currentThread().contextClassLoader
		try{
			Thread.currentThread().contextClassLoader = getClass().classLoader
			TerracottaConnect terracotta = new TerracottaConnect()
		} finally {
			Thread.currentThread().contextClassLoader = originalClassLoader
		}
	}

	@Override
	public void stop(BundleContext arg0) throws Exception {
		println "Goodbye."
	}

}
