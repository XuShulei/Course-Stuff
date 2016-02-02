package Resources;

import ProdCons.Cook;
import ProdCons.Eater;

public class Order implements Comparable<Order> {
	/* Record the order for each Eater */
	private int nBurger;		/* Number of burgers */
	private int nFries;			/* Number of fries */
	private int nCoke;			/* Number of cokes */
	private int orderTime;		/* Record the time that the eater actually make this order (i.e., after the eater getting a table and a cook is ready to serve) */
	private int servedTime;		/* The time all foods are ready */
	private int burgerTime;		/* The time one more burger is made */
	private int friesTime;		/* The time one more fries is made */
	private int cokeTime;		/* The time one more coke is made */
	private int cookTime;		/* Estimated total cooking time for this order */
	private boolean done;		/* Indicate this order is done or not */
	private Eater eater;		/* The eater corresponding to this order*/
	private Cook cook;			/* The cook who takes care of this order */
	public Order(Eater e, int nb, int nf, int nc) {
		/*Initialization*/
		eater = e;
		nBurger = nb;
		nFries = nf;
		nCoke = nc;
		done = false;
		cookTime = nBurger*5 + nFries*3 + nCoke;
	}
	public Order(Eater e, Order o) {
		/*Initialization*/
		eater = e;
		nBurger = o.getNumBurger();
		nFries = o.getNumFries();
		nCoke = o.getNumCoke();
		done = false;
		cookTime = nBurger*5 + nFries*3 + nCoke;
	}
	/* Record the time when certain food is made for this order */
	public void complete(int type, int time) {
		if (type == 0)
			completeBurger(time);
		else if (type == 1)
			completeFries(time);
		else
			completeCoke(time);
		if ((nBurger+nFries+nCoke) == 0)
			done = true;
	}
	/* Once a food is made, record the time and update the remaining amount */
	public void completeBurger(int t) {
		burgerTime = t;
		nBurger--;
	}
	public void completeFries(int t) {
		friesTime = t;
		nFries--;
	}
	public void completeCoke(int t) {
		cokeTime = t;
		nCoke--;
	}
	/* Following methods are just basic set/get of variables */
	public boolean isDone() {
		return done;
	}
	public void setDone(Cook c) {
		cook = c;
		done = true;
	}
	public void setOrderTime (int ot) {
		orderTime = ot;
	}
	public void setServingTime (int st) {
		servedTime = st;
	}
	public void setCook(Cook c) {
		cook = c;
	}
	
	public Cook getCook() {
		return cook;
	}
	public Eater getEater() {
		return eater;
	}
	public int getOrderTime () {
		return orderTime;
	}
	public int getServingTime () {
		return servedTime;
	}
	public int getBurgerTime () {
		return burgerTime;
	}
	public int getFriesTime () {
		return friesTime;
	}
	public int getCokeTime () {
		return cokeTime;
	}
	public int getNumBurger() {
		return nBurger;
	}
	public int getNumFries() {
		return nFries;
	}
	public int getNumCoke() {
		return nCoke;
	}
	public int getEstimateCookTime() {
		return nBurger*5 + nFries*3 + nCoke;
	}
	@Override
	public int compareTo(Order o) {
		/* Try to push the smallest order (based on estimated cooking time) to the first position in the Queue 
		 * Shortest Job First (SJF) strategy */
		int t = cookTime - o.getEstimateCookTime();
		/* If many orders are same estimated cooking time, then go for FIFO */
		if (t == 0)
			t = getEater().getSeq() - o.getEater().getSeq();
		return t;
	}
}
