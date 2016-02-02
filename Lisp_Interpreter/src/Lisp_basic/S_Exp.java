package Lisp_basic;

public class S_Exp {
	private int type;			//0: non-atom. 1: numeric atom 2: non-numeric atom, String or Special form such as T/NIL
	private int num_value;
	private String str_value;
	private S_Exp left;
	private S_Exp right;
	public S_Exp (S_Exp l, S_Exp r) {
		type = 0;
		left = l;
		right = r;
	}
	/* New S-exp, default is non-atom*/
	public S_Exp() {
		type = 2;
		str_value = "NIL";
		left = this;
		right = this;
	}
	/* New atom: number of others*/
	public S_Exp (String str) {
		/*remove white spaces, just in case, normally we should not need this*/
		int ws;
		StringBuilder sb = new StringBuilder(str);
		while ( (ws = sb.indexOf(" ")) != -1) {
			sb.deleteCharAt(ws);
		}
		str = sb.toString().toUpperCase();
		try {
			type=1;
			num_value = Integer.parseInt(str);
		} catch (NumberFormatException nn) {
			type = 2;
			if (str.length() == 0 || str.compareTo("NIL")==0) {
				str_value = "NIL";
			} else if (str.compareTo("T") == 0) {
				str_value = "T";
			} else {
				str_value = str;
			}
		}
	}
	/* New atom: number */
	public S_Exp(int n) {
		type=1;
		num_value = n;
	}
	public boolean isAtom() {
		return (type > 0);
	}
	public boolean isNIL() {
		return (type==2 && str_value.compareTo("NIL")==0);
	}
	public boolean isNum() {
		return (type==1);
	}
	public int getNum() {
		return num_value;
	}
	public String getStr() {
		return str_value;
	}
	public S_Exp getLeft() {
		return left;
	}
	public S_Exp getRight() {
		return right;
	}
	public String print() {
		StringBuilder sb = new StringBuilder();
		if (type==0) {
			sb.append("(");
			sb.append(left.print());
			sb.append(" . ");
			sb.append(right.print());
			sb.append(")");
		} else {
			if (type==1)
				sb.append(num_value+"");
			else 
				sb.append(str_value);
		}
		return sb.toString();
	}
	
	public String printList() {
		setListNum(0);
		//listNum = -1;
		return getList().toString();
		//return sb.reverse().toString();
	}
	//StringBuilder sb = new StringBuilder();
	private int listNum = -1;
	public int setListNum(int preLN) {
		if (!isAtom()) {
			listNum = preLN;
			if (right.isNIL())
				listNum++;
			if (!right.isAtom())
				listNum = right.setListNum(listNum);
			if(!left.isAtom())
				left.setListNum(listNum);
			System.out.println(print()+" >> "+listNum);
		}
		return listNum;
	}
	public StringBuilder getList() {
		StringBuilder sb = new StringBuilder();
		if (type==0) {
			if (right.isNIL()) {
				sb.append(left.getList());
			} else if (left.isAtom() && right.isAtom()){
				sb.append("(");	
				sb.append(left.print());
				sb.append(" . ");
				sb.append(right.print());
				sb.append(")");
			} else {
				int lln, rln;
				lln = (left.isAtom())?listNum:left.listNum;
				rln = (right.isAtom())?listNum:right.listNum;
				if (lln != listNum)
					sb.append("(");
				sb.append(left.getList());
				if (lln == rln)
					sb.append(" ");
				else
					sb.append(" . ");
				sb.append(right.getList());
				if (listNum != rln)
					sb.append(")");
			}
		} else {
			if (type==1)
				sb.append(num_value+"");
			/*else if (inList && type == 2 && str_value.compareTo("NIL")==0)
				sb.append("()");
			*/else
				sb.append(str_value.toUpperCase());
		}
		return sb;
	}
	
	/* for HashMap to create a hash code to check if two masks are equivalent or not*/
	@Override
	public int hashCode() {
		int hc = -1;
		if (type == 1)
			hc=num_value;
		else if (type == 2)
			hc = str_value.hashCode();
        return hc;
    }
	/* for HashMap to check if two S-Exps are equal*/
	@Override
	public boolean equals(Object obj) {
		boolean eq = false;
		S_Exp in = (S_Exp) obj;
		//System.out.println("compare types "+type+" and ");
		if ( type == in.type ) {
			switch (type) {
				case 0 : eq = (equals(in.left) && equals(in.right)) ; break;
				case 1 : eq = (num_value == in.num_value); break;
				default : eq = (str_value.compareTo(in.str_value)==0); break;
			}
		}
		return eq;
	}
}
