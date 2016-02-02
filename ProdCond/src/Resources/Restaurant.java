package Resources;
/* CSE 6431 Spring 2015 - Advanced Operating System -  Programming Assignment
 * Practice of synchronization primitives
 * Author: Ching-Hsiang Chu
 * Contact: chu.368@osu.edu
 * */

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;
import java.util.TreeSet;

import ProdCons.*;

public class Restaurant {
	public boolean readyToClose;			/* To indicate all eaters are served, so cooks' thread can terminate as well */
	public int time;						/* Global simulation time */
	public Machine burgerMachine;			/* Resource: one machine to make burger */
	public Machine friesMachine;			/* Resource: one machine to make fries */
	public Machine cokeMachine;				/* Resource: one machine to make coke */
	public ArrayList<Table> table;			/* Resource: Tables */
	public ArrayList<Cook> cook;			/* Resource: Cooks */
	public ArrayList<Eater> waitingEater;	/* Consumer: Eaters */
	public TreeSet<Order> pendingOrder;		/* Buffer: Eaters */
	public Restaurant (int ne, int nt, int nc) {
		/* Initialize all variables based on the input dataset */
		waitingEater = new ArrayList<Eater>(ne);
		pendingOrder = new TreeSet<Order>();
		table = new ArrayList<Table>(nt);
		for (int i=0 ; i<nt ; i++) {
			table.add(new Table(i+1));
		}
		cook = new ArrayList<Cook>(nc);
		for (int i=0 ; i<nc ; i++) {
			cook.add(new Cook(this, i+1));
		}
		burgerMachine = new Machine(0);
		friesMachine = new Machine(1);
		cokeMachine = new Machine(2);
		time = 0;
		readyToClose = false;
	}
	public ArrayList<Eater> getEaters() {
		return waitingEater;
	}
	public void newEater(int at, int nb, int nf, int nc) {
		/* Create a object for a eater, the object of Restaurant is one of parameter to ensure eaters will be competing for same resources  */
		waitingEater.add(new Eater(this,at,nb,nf,nc));
	}
	public void addEaters(ArrayList<Eater> elist) {
		for (Eater e : elist)
			waitingEater.add(new Eater(this,e));
	}
	public void start () {
		int i=1;
		/* Start cooks to be ready for eaters */
		for (Cook c : cook) {
			c.setPriority(1);	/*Let cooks have higher priority than eaters, to be awake more often to keep busy for cooking*/
			c.start();
		}
		/* Jump simulation time to the arrival time of the first arrived eater */
		time = waitingEater.get(0).getArrivalTime(); 
		/* Create thread one by one for all eaters, the sequence of creating threads is based on their arrival time */
		for (Eater e : waitingEater) {
			e.setSeq(i++); /* Debug use: Assign a sequence number */
			e.setPriority(2);
			e.start();
		}
		for (Eater e : waitingEater) {
			/* Wait all eaters finish */
			try {
				e.join();
			} catch (InterruptedException e1) {
				e1.printStackTrace();
			}
		}
		toClose();
		for (Cook c : cook) {
			try {
				c.join();
			} catch (InterruptedException e1) {
				e1.printStackTrace();
			}
		}
	}
	/* Generate the summary */
	public String report() {
		StringBuilder out = new StringBuilder();
		out.append("********** Restaurant is openning now! We have "+cook.size()+" cooks, "+table.size()+" tables **********\r\n");
		out.append("\r\n---------------------Customers' view ---------------------\r\n");
		for (Eater e : waitingEater) {
			out.append(e.getLog()+"\r\n");
		}
		out.append("\r\n---------------------Cooks' view ---------------------\r\n");
		for (Cook c : cook) {
			out.append(c.getLog()+"\r\n");
		}
		out.append("---------------------Machines' view ---------------------\r\n");
		out.append(burgerMachine.getLog());
		out.append("\t -----Made "+burgerMachine.getCount()+" burgers-----\r\n");
		out.append(friesMachine.getLog());
		out.append("\t -----Made "+friesMachine.getCount()+" fries-----\r\n");
		out.append(cokeMachine.getLog());
		out.append("\t -----Made "+cokeMachine.getCount()+" cokes-----\r\n");
		out.append("\r\n---------------------Tables' view ---------------------\r\n");
		for (Table t : table) {
			out.append(t.getLog()+"\r\n");
		}
		out.append("********** Restraurant is closed **********\r\n");
		out.append("All customers are served and left after "+time+" minutes from openning\r\n");
		return out.toString();
	}
	/* Synchronized method to update global time clock */
	public synchronized void updateTime(int t) {
		/* Make sure time is only increased */
		if (time < t)
			time = t;
	}
	/* Synchronized method to get global time clock */
	public synchronized int getTime() {
		return time;
	}	
	/* Synchronized method to notify cooks that restaurant is going to close */
	public synchronized void toClose() {
		readyToClose = true;
		notifyAll();
	}
	/* Synchronized method to check if the restaurant is going to close (mainly for cooks)*/
	public synchronized boolean isToClose() {
		return readyToClose;
	}
	/* Synchronized method for cooks to compete with each other for the machine */
	public synchronized void getMachine(Cook c, Order o) {
		try {
			boolean toWait = true;
			Machine m;
			/* Try to get any machine might need based on the order to avoid wasting time on acquiring only one machine
			 * For example, if burger machine is being used, then try to ask for fries/coke machine if they are also required */
			do {
				m = burgerMachine;
				if (o.getNumBurger()>0) {
					toWait = m.isUsing();
				}
				if (toWait && o.getNumFries()>0) {
					m = friesMachine;
					toWait = m.isUsing();
				}
				if (toWait && o.getNumCoke()>0) {
					m = cokeMachine;
					toWait = m.isUsing();
				}
				/* If required machines are used by other cook, just wait till it is available */
				if (toWait) {
					wait();
				}
			} while (toWait);
			/* Record the time the cook really got a machine */
			c.setServingTime(time);
			c.setMachine(m);
			/* Once got the machine, note it as taken (unavailable for other cooks) */
			m.taken();
			/* Notify other cook to compete/free the available machines */
			notifyAll();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	/* Synchronized method for cooks to release machine */
	public synchronized void releaseMachine (Machine m, int t) {
		/* Free the machine and record the time we finish cooking by using this machine based on the type of the food we made */
		m.reset();
		updateTime(t);
		/* Notify other cook to compete/free the available machines */
		notifyAll();
	}
	/* Synchronized method for Eaters to place their orders */
	public synchronized void placeOrder(Order o) {
		/* Add the order to the buffer to be taken by some cook */
		pendingOrder.add(o);
		/* Notify other eaters to place their orders */
		notifyAll();
		/* As long as the order is not done, the eater keep waiting */
		while (!o.isDone()) {
			try {
				wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	/* Synchronized method for cooks to take orders */
	public synchronized void takeOrder(Cook c) {
		/* If the order buffer is empty and restaurant is not close yet, cook just keep waiting for the order coming */
		while (pendingOrder.isEmpty() && !isToClose()) {
			try {
				wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		if (!pendingOrder.isEmpty()) {
			/* Cook takes the first order in the buffer */
			Order o = pendingOrder.pollFirst();
			c.setOrder(o.getEater(), time);
			o.setCook(c);
			notifyAll();
		}
	}
	/* Synchronized method for Eaters to be aware of the foods are ready */
	public synchronized void deliverFoods(int t) {
		updateTime(t);
		notifyAll();
	}
	/* Synchronized method for Eaters to compete with each other for the tables */
	public synchronized void getTable(Eater e) throws InterruptedException {
		int i=0;
		/* Check if any cook is available */
		for (; i<table.size() && !table.get(i).isAvailable() ; i++) {}
		/* If all tables are occupied, just keep waiting */
		while (i==table.size()) {
			try {
				wait();
			} catch (InterruptedException e1) {
				e1.printStackTrace();
			}
			/* Once begin notified, check again if any cook is available */
			for (i=0; i<table.size() && !table.get(i).isAvailable() ; i++) {}
			/* Record the time that eater is waiting */
			e.setLocalTime(time);
		}
		/* Once found a free table, occupy it */
		Table t = table.get(i);
		e.setTable(t);
		t.occupy(e, time);
		notifyAll();
	}
	/* Synchronized method for Eaters to free the tables */
	public synchronized void releaseTable(Table t) {
		t.reset(time);
		notifyAll();
	}
	
	/***** Main method *****/
	@SuppressWarnings({ "resource" })
	public static void main(String[] args) throws IOException {
		/* Open input from the file, default file name is input.txt if not specify */
		String inputfn = "input.txt";
		if (args.length > 0) 
			inputfn = args[0];
		File input = new File(inputfn);
		if ( !input.canRead() ) {
			System.out.println("Cannot read input file, please check it.\r\n");
			return;
		}
		/* Read input line by line, as the format that the assignment indicates */
		Scanner scan = new Scanner(input);
		int nEaters, nTable, nCook;
		if (scan.hasNextLine())
			nEaters = scan.nextInt();
		else {
			System.out.println("Incorrect input format\r\n");
			return;
		}
		if (scan.hasNextLine())
			nTable = scan.nextInt();
		else {
			System.out.println("Incorrect input format\r\n");
			return;
		}
		if (scan.hasNextLine())
			nCook = scan.nextInt();
		else {
			System.out.println("Incorrect input format\r\n");
			return;
		}
		/* Create the object of Restaurant with given dataset */
		Restaurant baseRest = new Restaurant(nEaters, nTable, nCook);
		int at, nb, nf, nc;
		for (int i=0 ; i<nEaters && scan.hasNextLine() ; i++) {
			/* Read in the arrival time and their orders */
			at = scan.nextInt();
			nb = scan.nextInt();
			nf = scan.nextInt();
			nc = scan.nextInt();
			/* Create a Eater object with their arrival time and order from each input file*/
			baseRest.newEater(at,nb,nf,nc);
		}
		scan.close();
		/* Sort Eaters by arrive time */
		Collections.sort(baseRest.waitingEater);
		Restaurant bestRest = new Restaurant(nEaters, nTable, nCook);
		/* Start running the simulations 
		 * We set series of runs since we cannot fully control the awake sequence by using wait()/notifyAll(), which might affect the result
		 * Default: running 10 times to find the best performance among them */
		int round = (args.length>1)?Integer.parseInt(args[1]):10, min=-1;
		Restaurant rest[] = new Restaurant[round];
		System.out.println("Simulating...");
		for (int i=0 ; i<round ; i++) {
			rest[i] = new Restaurant(nEaters, nTable, nCook);
			rest[i].addEaters(baseRest.getEaters());
			rest[i].start();
			if (min==-1 || rest[i].getTime() < min) {
				min = rest[i].getTime();
				bestRest = rest[i];
			}
		}
		System.out.println(bestRest.report());
		Writer w = new FileWriter("out_"+inputfn);
		w.write(bestRest.report());
		w.close();
	}
}