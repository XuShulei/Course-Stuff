package Resources;

public class Machine {
	/* Only three types of food served by the restaurant
	 * There is only one machine of each type in the restaurant: 
	 * type 0: Buckeye Burger (>=1): working time is 5 minutes
	 * type 1: Brutus Fries(>=0): working time is 3 minutes
	 * type 2: Coke(>=0): working time is 1 minutes
	 *  */
	private int type; 
	private int workingTime;
	private boolean using;		/* Indicate whether the machine is available or not */
	private int count;			/* Record how many food are made by this machine */ 
	private StringBuilder log;
	public Machine (int t) {
		/* Initialize variables */
		type = t;
		count = 0;
		log = new StringBuilder();
		if (type == 0) {
			workingTime = 5;
			log.append("Burger Machine: \r\n");
		}
		else if (type == 1){
			workingTime = 3;
			log.append("Fries Machine: \r\n");
		}
		else {
			workingTime = 1;
			log.append("Coke Machine: \r\n");
		}
		using = false;		
	}
	/* To check if this machine is using by some cook */
	public boolean isUsing() {
		return using;
	}
	/* Being called to assign this machine to the cook who won the competition */
	public void taken() {
		using = true;
	}
	/* Making food, simply make the thread to sleep for the given time */
	public void working(int t) {
		try {
			log.append("\t Working from "+t+" to "+(t+workingTime)+"\r\n");
			Thread.sleep(workingTime);
			count++;
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	/* Reset the variables to make it available */
	public void reset() {
		using = false;
	}
	/* Following methods are just basic set/get of variables */
	public int getWorkingTime() {
		return workingTime;
	}
	public String getLog() {
		return log.toString();
	}
	public int getType() {
		return type;
	}
	public int getCount() {
		return count;
	}
}
