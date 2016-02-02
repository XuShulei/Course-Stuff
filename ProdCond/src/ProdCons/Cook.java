package ProdCons;

import Resources.*;

public class Cook extends Thread {
	private Restaurant r;				/* Indicates the location of methods to compete the resources (Machines) */
	private Eater servingEater;			/* Indicates the Eater who is serving by this cook */
	private Machine machine;			/* The machine, which the cook is using*/
	private Order order;				/* Indicates the Order, this cook is working with */
	private int servingTime;			/* Record the (local) time used for serving current Eater */
	private int number;					/* Give a number to each cook */
	private StringBuilder log;
	public Cook(Restaurant r, int n) {
		this.r = r;
		number = n;
		log = new StringBuilder();
		log.append("Cook "+number+": \r\n");
	}
	/* To check if this cook is available, in other words, whether serving any eater or not */
	public boolean isAvailable() {
		return (servingEater == null);
	}
	public void run () {
		while (!r.isToClose()) {
			try {
				r.takeOrder(this);
				if (order != null) {
					serving();
					r.deliverFoods(servingTime);
				}
				reset();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		//log.append(log.toString());
	}
	public void setMachine(Machine m) {
		machine = m;
	}
	/* Getting the order based on the eater to be serving as well as the time the cook really got an order*/
	public void setOrder(Eater e, int time) {
		servingEater = e;
		order = e.getOrder();
		servingTime = time;
		order.setOrderTime(servingTime);
		log.append("\t Start processing order from Customer "+servingEater.getSeq()+" at "+servingTime+"\r\n");
	}
	public void cooking() {
		/* Working the food */
		String mName = (machine.getType()==0)?"Burger":(machine.getType()==1)?"Fries":"Coke";
		log.append("\t Making "+mName+" from "+servingTime+" to ");
		machine.working(servingTime);
		servingTime += machine.getWorkingTime();
		log.append(servingTime+"\r\n");
	}
	/* To compete resources (Machines) with other Cook */
	public void serving() throws InterruptedException {
		//Order copyOrder = new Order(order);
		while (!order.isDone()) {
			r.getMachine(this, order);
			cooking();
			order.complete(machine.getType(), servingTime);
			r.releaseMachine(machine, servingTime);
		}
		/* After the order is made, set the finish time and make cook itself available (not having serving Eater) */
		order.setServingTime(servingTime);
		order.setDone(this);
		log.append("\t Order from Customer "+servingEater.getSeq()+" is completed at "+servingTime+"\r\n");
	}
	public void reset() {
		servingEater = null;
		order = null;
	}
	/* Following methods are just basic set/get of variables */
	public String getLog() {
		return log.toString();
	}
	public int getSeq () {
		return number;
	}
	public void setServingTime(int t) {
		/* Make sure time is only increased */
		if ( t >servingTime )
			servingTime = t;
	}
}