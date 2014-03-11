package terracottawithgroovy
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

class AJob implements Job{
	@Override
	public void execute(JobExecutionContext arg0) throws JobExecutionException {
		println "[" + new Date() + "]" + "Job is executing..."
	}
}