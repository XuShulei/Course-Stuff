package Lisp_basic;

import java.util.HashMap;
import java.util.Set;

public class Lisp_primitive {
	private String primitive[] = {	"T", "NIL", "CAR","CDR", "CONS", "ATOM", "EQ", "NULL", "INT", 
									"PLUS","MINUS", "TIMES", "QUOTIENT", "REMAINDER", 
									"LESS", "GREATER", "COND", "QUOTE",  "DEFUN"};						
	private String errMsg;
	private String warMsg;
	private boolean errflag=false;
	private HashMap<Integer, S_Exp> atoms; 
	S_Exp d_list;	//function definition
	/* T/NIL are referred a lot in the following methods, so make a global reference*/
	private S_Exp sT ;
	private S_Exp sNIL; 
	public Lisp_primitive(HashMap<Integer, S_Exp> a){
		errMsg = new String();
		warMsg = new String();
		atoms = a;
		d_list = new S_Exp();
		for (String str : primitive ) {
			atoms.put(str.hashCode(), new S_Exp(str));
		}
		sT = atoms.get("T".hashCode());
		sNIL = atoms.get("NIL".hashCode());
	}
	public void clear() {
		errMsg = new String();
		warMsg = new String();
		errflag=false;
	}
	public String getErrMsg() {
		return errMsg;
	}
	public String getWarMsg() {
		return warMsg;
	}
	public String getFuncs() {
		StringBuilder str = new StringBuilder();
		str.append("Primitive functions: ");
		for ( int i = 2 ; i<primitive.length ; i++) {
			str.append("\""+primitive[i]+"\", ");
		}
		str.append("\r\nUser-defined functions: ");
		S_Exp list = d_list;
		while ( !NULL(list) ) {
			str.append("\""+CAR(CAR(list)).printList()+"\", ");
			list = CDR(list);
		}
		str.append("\r\n");
		return str.toString();
	}
	public S_Exp getVal(S_Exp target, S_Exp list) {
		//System.out.println("getVal: "+target.print()+" from "+CAR(list).print());
		if (CAR(CAR(list)).equals(target)) {
			return CDR(CAR(list));
		} else if (list.isNIL() && !target.isNIL()) {
			return sNIL;
		} else {
			return getVal(target, CDR(list));
		}
	}
	public boolean isInList(S_Exp target, S_Exp list) {
		boolean found = false;
		if (NULL(list)) {
			found = false;
		} else if (CAR(CAR(list)).equals(target)) {
			found = true;
		} else {
			found = isInList(target, CDR(list));
		}
		return found;
	}
	public S_Exp addpair(S_Exp pList, S_Exp x, S_Exp a_list) {
		S_Exp nLeft;
		//System.out.println("addpair: "+pList.print()+" with "+x.print()+" to "+a_list.print());
		while (!CAR(pList).isNIL() && !CAR(x).isNIL()) {
			nLeft = CONS(CAR(pList), CAR(x));
			a_list = CONS(nLeft, a_list);
			pList = CDR(pList);
			x = CDR(x);
		} 
		return a_list;
	}
	public S_Exp apply(S_Exp f, S_Exp x, S_Exp a_list) {
		if (errflag) 
			return sNIL;
		S_Exp out = sNIL;
		int np = numParameters(x);
		//System.out.println("APPLY: "+f.print()+" to "+x.print()+" with "+np+" parameters and a_list "+a_list.print());
		if (ATOM(f)) {
			if ( EQ(f, atoms.get("CAR".hashCode())) ) {
				if (np != 1) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 1 arguments";
					errflag=true;
				} else
					out = CAR(CAR(x));
			} else if ( EQ(f, atoms.get("CDR".hashCode())) ) {
				if (np != 1) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 1 arguments";
					errflag=true;
				} else
					out = CDR(CAR(x));
			} else if ( EQ(f, atoms.get("CONS".hashCode())) ) {
				if (np != 2) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 2 arguments";
					errflag=true;
				} else
					out = CONS(CAR(x), CAR(CDR(x)));
			} else if ( EQ(f, atoms.get("ATOM".hashCode())) ) {
				if (np != 1) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 1 arguments";
					errflag=true;
				} else
					out = (ATOM(CAR(x)))?sT:sNIL;
			} else if ( EQ(f, atoms.get("NULL".hashCode())) ) {
				if (np != 1) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 1 arguments";
					errflag=true;
				} else
					out = (NULL(CAR(x)))?sT:sNIL;
			} else if ( EQ(f, atoms.get("INT".hashCode())) ) {
				if (np != 1) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 1 arguments";
					errflag=true;
				} else
					out = (INT(CAR(x)))?sT:sNIL;
			} else if ( EQ(f, atoms.get("EQ".hashCode())) ) {
				if (np != 2) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 2 arguments";
					errflag=true;
				} else
					out = (EQ(CAR(x), CAR(CDR(x))))?sT:sNIL;
			} else if ( EQ(f, atoms.get("PLUS".hashCode())) ) {
				if (np != 2) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 2 arguments";
					errflag=true;
				} else
					out = PLUS(CAR(x), CAR(CDR(x)));
			} else if ( EQ(f, atoms.get("MINUS".hashCode())) ) {
				if (np != 2) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 2 arguments";
					errflag=true;
				} else
					out = MINUS(CAR(x), CAR(CDR(x)));
			} else if ( EQ(f, atoms.get("TIMES".hashCode())) ) {
				if (np != 2) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 2 arguments";
					errflag=true;
				} else
					out = TIMES(CAR(x), CAR(CDR(x)));
			} else if ( EQ(f, atoms.get("QUOTIENT".hashCode())) ) {
				if (np != 2) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 2 arguments";
					errflag=true;
				} else
					out = QUOTIENT(CAR(x), CAR(CDR(x)));
			} else if ( EQ(f, atoms.get("REMAINDER".hashCode())) ) {
				if (np != 2) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 2 arguments";
					errflag=true;
				} else
					out = REMAINDER(CAR(x), CAR(CDR(x)));
			} else if ( EQ(f, atoms.get("LESS".hashCode())) ) {
				if (np != 2) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 2 arguments";
					errflag=true;
				} else
					out = LESS(CAR(x), CAR(CDR(x)));
			} else if ( EQ(f, atoms.get("GREATER".hashCode())) ) {
				if (np != 2) {
					errMsg = "Too few/many arguments for \""+f.print()+"\", which needs 2 arguments";
					errflag=true;
				} else
					out = GREATER(CAR(x), CAR(CDR(x)));
			} else {
				S_Exp val = getVal(f, d_list);
				//System.out.println("USE-DEFINED: "+CDR(val).print()+" and "+CAR(val).print()+" with a_list "+addpair(CAR(val), x, a_list).print());
				if (val.isNIL() && !f.isNIL()) {
					if (errMsg.isEmpty())
						errMsg += "Undefined function \""+f.print()+"\"";
					errflag = true;
				} else if (numParameters(CAR(val)) != np) {
					if (errMsg.isEmpty())
						errMsg += "Too few/many arguments for \""+f.print()+"\", which needs "+numParameters(CAR(val))+" arguments";
					errflag = true;
				} else {
					out = eval(CDR(val), addpair(CAR(val), x, a_list) );
				}		
			}
		} else {
			if (errMsg.isEmpty())
				errMsg = "Failed on apply \""+f.printList()+"\"";
			errflag = true;
		}
		//System.out.println("Done APPLY: "+f.print()+" to "+x.print()+" with a_list "+a_list.print()+" >>> "+out.print());
		return out;
	}
	public S_Exp eval(S_Exp in) {
		return eval(in, sNIL);
	}
	public S_Exp eval(S_Exp in, S_Exp a_list) {
		if (errflag) 
			return sNIL;
		S_Exp out = sNIL;
		//System.out.println("EVAL: "+in.print()+" with a_list "+a_list.print());
		if (ATOM(in)) {
			if (INT(in)) {
				out = in;
			} else if (EQ(in,sNIL)) {
				out = sNIL;
			} else if (EQ(in,sT)) {
				out = sT;
			} else if (isInList(in, a_list)) {
				out = getVal(in, a_list);
			} else {
				if (errMsg.isEmpty())
					errMsg = "unbounded variable \""+in.printList()+"\"";
				errflag = true;
			}
		} else if (ATOM(CAR(in))) {
			S_Exp carIn = CAR(in); 
			if (EQ(carIn, atoms.get("QUOTE".hashCode()))) {
				out = CAR(CDR(in));			
			} else if (EQ(carIn, atoms.get("COND".hashCode()))) {
				out = evcond(CDR(in),a_list);
			} else if (EQ(carIn, atoms.get("DEFUN".hashCode()))) {
				if (numParameters(CDR(in)) != 3) {
					errMsg = "Too few/many arguments for \"DEFUN\", which needs 3 arguments";
					errflag=true;
				} else
					out = DEFUN(CDR(in));
			} else {
				out = apply(carIn, evlis(CDR(in), a_list), a_list );
			}
		} else {
			if (errMsg.isEmpty())
				errMsg = "Failed on eval \""+in.printList()+"\"";
			errflag = true;
		}
		/* Only record the error for the correct position of evaluation*/
		if (!errMsg.isEmpty() && !errMsg.contains("eval"))
			errMsg = "Failed on eval \""+in.printList()+"\"\r\n \t because "+errMsg;
		//System.out.println("DONE EVAL: "+in.print()+"  >>>   "+out.print());
		return out;
	}
	public S_Exp evlis(S_Exp in, S_Exp a_list) {
		if (errflag) 
			return sNIL;
		S_Exp out = sNIL;
		//System.out.println("EVLIS: "+in.print()+" with a_list "+a_list.print());
		if (NULL(in) ) {
			out = sNIL;
		} else if (ATOM(in)) {
			out = eval(in);
		} else {
			out = CONS(eval(CAR(in), a_list), evlis(CDR(in),a_list));
		}
		//System.out.println("DONE EVLIS: "+in.print()+" with a_list "+a_list.print()+"  >>>   "+out.print());
		return out;
	}
	public S_Exp evcond(S_Exp be, S_Exp a_list) {
		if (errflag) 
			return sNIL;
		S_Exp out = sNIL;
		//System.out.println("EVCOND: "+be.print()+" with a_list "+a_list.print());
		if (NULL(be)) {
			if (errMsg.isEmpty())
				errMsg = "Reach undefined condition";
			errflag = true;
		} else if (eval(CAR(CAR(be)),a_list).equals(sT)) {
			out = eval(CAR(CDR(CAR(be))), a_list);
		} else {
			out = evcond(CDR(be), a_list);
		}
		//System.out.println("Done EVCOND: "+be.print()+" with a_list "+a_list.print()+"  >>>   "+out.print());
		return out;
	}
	public int numParameters(S_Exp in) {
		int n=(NULL(in))?0:1;
		S_Exp tmp = in;
		while (!CDR(tmp).equals(sNIL)) {
			tmp = CDR(tmp);
			n++;
		}
		return n;
	}
	public S_Exp CONS(S_Exp left, S_Exp right) {
		return new S_Exp(left, right);
	}
	public S_Exp CAR(S_Exp in) {
		S_Exp out = sNIL;
		if (!in.isNIL() && in.isAtom()) {
			//if (errMsg.isEmpty())
			//	errMsg = "Perfome CAR for an atom "+in.print();
			//errflag = true;
		} else if (!in.isNIL())
			out = in.getLeft();
		return out;
	}
	public S_Exp CDR(S_Exp in) {
		S_Exp out = sNIL;
		if (!in.isNIL() && in.isAtom()) {
			//if (errMsg.isEmpty())
			//	errMsg = "Perfome CDR for an atom "+in.print();
			//errflag = true;
		} else if (!in.isNIL())
			out = in.getRight();
		return out;
	}
	public boolean EQ(S_Exp first, S_Exp second) {
		//System.out.println("EQ: "+first.print()+" to "+second.print());
		return first.equals(second);
	}
	public boolean NULL(S_Exp in) {
		return in.isNIL() ;
	}
	public boolean ATOM(S_Exp in) {
		return in.isAtom();
	}
	public boolean INT(S_Exp in) {
		return in.isNum();
	}
	/* Numberic operations: type 0: PLUS, 1: MINUS, 2: TIMES, 3: QUOTIENT, 4: REMAINDER, 5: LESS, 6: GREATER  */
	public S_Exp numOperation(S_Exp first, S_Exp second, int type) {
		S_Exp out = atoms.get("NIL".hashCode());
		if (!first.isNum() || !second.isNum()) {
			String op = new String();
			switch (type) {
				case 0 : op = "PLUS"; break;
				case 1 : op = "MINUS"; break;
				case 2 : op = "TIMES"; break;
				case 3 : op = "QUOTIENT"; break;
				case 4 : op = "REMAINDER"; break;
				case 5 : op = "LESS"; break;
				case 6 : op = "GREATER"; break;
				default : op = "Undefined operation"; break;
			}
			if (type > 6)
				errMsg = op;
			else
				errMsg = "Non-numeric atom for \""+op+"\"";
			errflag = true;
		}
		else {
			int ans=0;
			switch (type) {
				case 0 : ans = first.getNum() + second.getNum(); break;
				case 1 : ans = first.getNum() - second.getNum(); break;
				case 2 : ans = first.getNum() * second.getNum(); break;
				case 3 : ans = first.getNum() / second.getNum(); break;
				case 4 : ans = first.getNum() % second.getNum(); break;
				case 5 : ans = (first.getNum() < second.getNum())?"T".hashCode():"NIL".hashCode(); break;
				case 6 : ans = (first.getNum() > second.getNum())?"T".hashCode():"NIL".hashCode();; break;
			}
			if (atoms.containsKey(ans))
				out = atoms.get(ans);
			else
				out = new S_Exp(ans);
		}
		return out;
	}
	public S_Exp PLUS(S_Exp first, S_Exp second) {
		return numOperation(first,second,0);
	}
	public S_Exp MINUS(S_Exp first, S_Exp second) {
		return numOperation(first,second,1);
	}
	public S_Exp TIMES(S_Exp first, S_Exp second) {
		return numOperation(first,second,2);
	}
	public S_Exp QUOTIENT(S_Exp first, S_Exp second) {
		return numOperation(first,second,3);
	}
	public S_Exp REMAINDER(S_Exp first, S_Exp second) {
		return numOperation(first,second,4);
	}
	public S_Exp LESS(S_Exp first, S_Exp second) {
		return numOperation(first,second,5);
	}
	public S_Exp GREATER(S_Exp first, S_Exp second) {
		return numOperation(first,second,6);
	}
	public S_Exp QUOTE(S_Exp in) {
		return in;
	}
	/*public S_Exp COND(S_Exp in) {
		return in;
	}*/
	public S_Exp DEFUN(S_Exp in) {
		S_Exp fname = CAR(in);
		S_Exp p_list = CAR(CDR(in));
		S_Exp body = CAR(CDR(CDR(in)));
		S_Exp newFun = CONS ( fname, CONS(p_list, body));
		if (isInList(fname, d_list)) {
			warMsg = "Redefining an existed function \""+CAR(in).printList()+"\", old one will be overwritten ";
		}
		if (NULL(body)) {
			if (!warMsg.isEmpty())
				warMsg += "\r\n";
			warMsg += "Defining function \""+CAR(in).printList()+"\", with empty body";
		}
		d_list = CONS(newFun, d_list);
		return CAR(in);
	}
	public String[] getPrimitives() {
		return primitive;
	}
}
