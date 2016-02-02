package Resources;

import ProdCons.*;

public class Table {
	/* Only record the information, and being accessed */
	private Eater servingEater;	/* The eater seating currently */
	private int number;			/* Table Number */
	private StringBuilder log;	/* log file */
	public Table(int n) {
		number = n;
		servingEater = null;
		log = new StringBuilder();
		log.append("Table "+number+":\r\n");
	}
	public boolean isAvailable() {
		return (servingEater == null);
	}
	public void occupy(Eater e, int t) {
		servingEater = e;
		log.append("\t Seated by Customer "+e.getSeq()+" from "+t);
	}
	public void reset(int t) {
		servingEater = null;
		log.append(" to "+t+"\r\n");
	}
	public int getSeq() {
		return number;
	}
	public String getLog() {
		return log.toString();
	}
}