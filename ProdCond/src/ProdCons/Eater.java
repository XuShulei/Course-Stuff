package ProdCons;
import Resources.*;

public class Eater extends Thread implements Comparable<Eater> {
	private Restaurant visitRest;	/* The Restaurant this eater visited, to make sure eaters are competeting for same resources */
	private Order order;			/* The Order the eater made*/
	private Table myTable;
	private int arriveTime;			/* Arrival time of the eater */
	private int localTime;			/* Record the time that the eater actually got a table and cook regardless global timer */
	private int finishTime;			/* Record the time that the eater finish eating */
	private int eaterSeq;	   		/* Sequence number for eater */
	private StringBuilder log = new StringBuilder();
	
	public Eater( Restaurant r, int at, int nb, int nf, int nc) {
		/* Initialize variables */
		visitRest = r;
		arriveTime=at;
		localTime = arriveTime;
		order = new Order(this, nb,nf,nc);
	}
	public Eater (Restaurant r, Eater e) {
		/* Initialize variables */
		visitRest = r;
		arriveTime=e.getArrivalTime();
		localTime = arriveTime;
		order = new Order(this, e.getOrder());
	}
	/* Start the thread to compete resources with other threads(eaters)*/
	public void run() {
	    try {
	    	/* Waiting period of time to make sure the order of eaters */
	    	if (arriveTime > visitRest.getTime())
	    		Thread.sleep((arriveTime - visitRest.getTime()));
	    	visitRest.updateTime(arriveTime);
	    	log.append("Customer "+eaterSeq+" coming at "+arriveTime+":\r\n");
	    	//log.append("Customer "+eaterSeq+" comming at "+arriveTime+", now is "+getTime());
	    	/* First, try to occupy a table in the Restaurant, in the synchronized method */
	    	visitRest.getTable(this);
	    	log.append("\t seated table "+myTable.getSeq()+" at "+localTime+"\r\n");
	    	/* Second, try to place the order, in the synchronized method 
	    	 * Eater will be waiting inside till the order has been taken care of*/
	    	visitRest.placeOrder(order);
	    	log.append("\t got all foods at "+order.getServingTime() +" by Cook "+order.getCook().getSeq()+" started at "+order.getOrderTime());
	    	log.append(" (Burgers are made at "+order.getBurgerTime());
			if (order.getFriesTime() > 0)
				log.append(", Fries are made at "+order.getFriesTime());
			if (order.getCokeTime() > 0)
				log.append(", Cokes are made at "+order.getCokeTime());
			log.append(")");
	    	/* Eater takes exactly 30 minutes to finish eating, and leave immediately*/
	    	Thread.sleep(30);
	    	finishTime = order.getServingTime()+30;
	    	/* update the global time if necessary before leave */
	    	visitRest.updateTime(finishTime);
	    	/* After finishing the food, free the table and leave (close the thread) */
	    	visitRest.releaseTable(myTable);		    	
	    } catch (InterruptedException e) {
	    	log.append("Customer(Thread) " + eaterSeq + " is interrupted.");
	    }
	    log.append("\r\n\t Customer " + eaterSeq +" leave at " +  finishTime);
	}
	/* Following methods are just basic set/get of variables */
	public void setSeq(int seq) {
		eaterSeq = seq;
	}
	public void setTable (Table t) {
		myTable = t;
	}
	public void setLocalTime(int t) {
		localTime = t;
	}
	public Order getOrder () {
		return order;
	}
	public int getLocalTime() {
		return localTime;
	}
	public int getArrivalTime() {
		return arriveTime;
	}
	public String getLog() {
		return log.toString();
	}
	public int getSeq() {
		return eaterSeq;
	}
	/* Using the arrival time to distinguish eaters, for sorting purpose */
	@Override
	public int compareTo(Eater obj) {
		return getArrivalTime() - obj.getArrivalTime();
	}
}