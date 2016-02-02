import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Scanner;
import java.util.Stack;

import Lisp_basic.*;


public class Lisp_interpreter {
	public static Lisp_primitive primitive;
	public static Lisp_tree tree ;
	public static boolean debug=false;
	public static class Lisp_tree {
		private S_Exp root;
		private S_Exp cur;
		private StringBuilder org_input;
		private StringBuilder input;
		private Stack<Integer> leftBracket;
		private Stack<S_Exp> pendingSexp;
		private HashMap<Integer, S_Exp> atoms;
		private int curPos;
		private String errMsg;
		private boolean legal;
		private int numList;
		public Lisp_tree (){
			input = new StringBuilder();
			org_input = new StringBuilder();
			leftBracket = new Stack<Integer>();
			pendingSexp = new Stack<S_Exp>();
			errMsg = new String();
			curPos = 0;
			legal = true;
			atoms = new HashMap<Integer, S_Exp>();
			numList = 0;
		}
		public HashMap<Integer, S_Exp> getAtoms() {
			return atoms;
		}
		/*Debug only*/
		public void printAtomList() {
			System.out.println("Current stored atoms ("+atoms.size()+"): ");
			for (S_Exp v : atoms.values()) {
				System.out.print(v.print()+", ");
			}
		}
		public void printTree () {
			System.out.print("> ");
			System.out.print(root.print());
			System.out.println();	
		}
		public S_Exp getFullSExp() {
			if (legal && leftBracket.isEmpty() && pendingSexp.isEmpty() && input.length() > 0) {
				/*input is just an atom*/
				pendingSexp.push(new S_Exp(input.toString()));
			}
			if (legal && pendingSexp.size() == 1) {
				/* Correct S-Exp has parsed */
				root = pendingSexp.pop();
				/*System.out.print("> ");
				System.out.print(root.print());
				System.out.println();*/
			} else {
				/* Incorrect input for some reason */
				root = atoms.get("NIL".hashCode());
				if (input.length() > 0)
					errMsg = "incorrect number of parenthesis pairs or other error did not capture precisely";
				legal=false;
				//System.out.println("**error: "+errMsg+"**");
			}
			return root;
		}
		public String  getError () {
			return this.errMsg;
		}
		public boolean isEmpty() {
			return (pendingSexp.isEmpty());
		}
		public boolean islegal() {
			return legal;
		}
		public void clear() {
			leftBracket = new Stack<Integer>();
			pendingSexp = new Stack<S_Exp>();
			//atoms = new HashSet<S_Exp>();
			input.setLength(0);
			org_input.setLength(0);
			curPos = 0;
			errMsg = new String();
			legal = false;
			numList = 0;
		}
		public boolean read(String str) {
			org_input.append(str);
			str = removeWhiteSpaces(new StringBuilder(str));
			input.append(str);
			if (str.indexOf('$') == -1) {
				legal = true;
			} else {
				errMsg = "unexpected dollar sign";
				legal = false;
			}
			//System.out.println("\""+input.toString()+"\"");
			return legal;
		}
		public String removeWhiteSpaces(StringBuilder str) {
			/* eliminate unnecessary white space in the input */
			/* remove beginning white spaces if this is the first sentence */
			while ( input.length() == 0 && str.charAt(0) == ' ' ) {
				str.deleteCharAt(0);
			}
			int ws = 0;
			/* replace TAB by white space*/
			while ( (ws = str.indexOf("\t", ws)) != -1 ) {
				//System.out.println("capture tab at "+ws);
				str.deleteCharAt(ws);
				if (ws != 0)
					str.insert(ws, " ");
			}
			ws = 0;
			/* eliminate unnecessary white space in the input for some known relationship in the Lisp expression */
			char lastChar, nextChar;
			while ( (ws = str.indexOf(" ", ws)) != -1 ) {
				/* for the case when input crossing multiple lines, and some line starts with space*/
				if ( (ws-1) < 0 )
					lastChar = (input.length()>0)?input.charAt(input.length()-1):' ';
				else
					lastChar = str.charAt(ws-1);
				/* for the case when reaching end of string*/
				if ( (ws+1) >= str.length() )
					nextChar = '\0';
				else
					nextChar = str.charAt(ws+1);
				if ( nextChar == ' ' 
						|| nextChar == '.'  || lastChar == '.'
						|| lastChar == '('  || nextChar == ')' )
				{
					str.deleteCharAt(ws);
				} else {
					ws++;
				}
			}
			return str.toString();
		}
		public int buildTree(String str) {
			int type = 0; //0: illegal. 1: list. 2: normal non-atom S_Exp
			/*First split by dot*/
			String at[] = str.split("\\.");
			if (at.length > 2) {
				/*more than one dot => illegal*/
				type=0;
				errMsg = "unexpected dot(s)";
			} else if (at.length == 1) {
				// Could be a List
				if (str.indexOf('.') != -1) {  // To deal with the situation like (1.)
					type=0;
					errMsg = "unexpected dot(s) or uncomplete S-Expression";
				} else {
					at = str.split(" ");
					S_Exp nleft, nright = atoms.get("NIL".hashCode());
					for (int i=at.length-1 ; i>=0 ; i--) {
						if (at[i].length() > 0) {
							nleft = (at[i].charAt(0) == '(') ? pendingSexp.pop() : (new S_Exp(at[i]));
							if (atoms.containsKey(nleft.hashCode()))
								nleft = atoms.get(nleft.hashCode());
							else if (nleft.isAtom())
								atoms.put(nleft.hashCode(), nleft);
							nright = new S_Exp(nleft, nright);
						}
					}
					numList++;
					cur = nright;
					type = 1;
				}
			} else {
				// Normal non-atom S-Exp
				S_Exp nleft, nright;
				if (at[1].length() == 0 ) {		
					// empty after dot
					type = 0 ;
					errMsg = "uncomplete S-Expression after dot";
				} else if (at[1].indexOf(' ') != -1) {
					// mix of white space and dot inside a parenthesis pair => illegal
					type = 0 ;
					errMsg = "confusing between non-atomic S-Exp and List";
				} else {
					nright = (at[1].charAt(0) == '(') ? pendingSexp.pop() : (new S_Exp(at[1]));
					if (atoms.containsKey(nright.hashCode()))
						nleft = atoms.get(nright.hashCode());
					else if (nright.isAtom())
						atoms.put(nright.hashCode(), nright);
					if (at[0].length() == 0 ) {
						// empty before dot
						type = 0 ;
						errMsg = "uncomplete S-Expression before dot";
					} else if (at[0].indexOf(' ') != -1) {
						// mix of white space and dot inside a parenthesis pair => illegal
						type = 0 ;
						errMsg = "confusing between non-atomic S-Exp and List";
					} else {
						/* legal syntax*/
						nleft = (at[0].charAt(0) == '(') ? pendingSexp.pop() : (new S_Exp(at[0].toString()));
						if (atoms.containsKey(nleft.hashCode()))
							nleft = atoms.get(nleft.hashCode());
						else if (nleft.isAtom())
							atoms.put(nleft.hashCode(), nleft);
						cur = new S_Exp(nleft, nright);
						type = 2;		
					}
				}
			}
			return type;
		}
		public boolean parse(String str) {
			if (input.length() == 0 || legal) 
				legal = read(str);
			if (legal) {
				int lastLeftBracket=0, lastDot, lastSpace, lastType;
				for ( ; curPos<input.length() && legal ; curPos++) {
					switch(input.charAt(curPos)) {
						case '(' : 	if ( leftBracket.isEmpty() && curPos > 0) {
										legal=false;
										errMsg = "incorrect position of parenthesis";
									} else {
										leftBracket.push(curPos); 
									}
									break;
						case ')' : 	
									if (leftBracket.isEmpty()) {
										legal=false;
										errMsg = "incorrect number of parenthesis pairs";
									} else {
										lastLeftBracket = leftBracket.pop(); 
										if ( (lastType=buildTree(input.substring(lastLeftBracket+1, curPos))) > 0 ) {
											pendingSexp.push(cur);
											if (lastType == 1) {
												/* last S-Exp is a legal List, remove the white spaces between these parsed parenthesis pair */
												while ( ((lastSpace = input.indexOf(" ",lastLeftBracket+1)) != -1 && lastSpace<curPos)) {
													input.deleteCharAt(lastSpace);
													curPos--;
												}
											}
											else if (lastType == 2) {
												/* last S-Exp is a legal non-atom S-Exp, remove the dot between these parsed parenthesis pair */
												lastDot = input.indexOf(".",lastLeftBracket+1);	
												if (lastDot!=-1)  {
													input.deleteCharAt(lastDot);
													curPos--;
												}
											}
										}
										else {
											legal=false;
											if (errMsg.isEmpty())
												errMsg = "incorrect number of parenthesis pairs";
										}
									}
									break;
						case '.' :  if (input.charAt(curPos-1) == '(') {
										legal=false;
										errMsg = "uncomplete S-Expression before dot";
									} else if (leftBracket.isEmpty() ) {
										legal=false;
										errMsg = "incorrect number of parenthesis pairs";
									}
									break;
						default : 	
									break;
					}
				}						
				curPos = input.length();
			}
			return legal;
		}
		public boolean eval() {
			
			return true;
		}
	}
	public static void printWelcome() {
		System.out.println(
				"--------------------------------------------------------------------------------\r\n"
				+ "Welcome to use Lisp Intepreter\r\n"
				+ "This program is written for the lab assignment of CSE 6341 Programing Language\r\n"
				+ "Author: Ching-Hsiang Chu\r\n"
				+ "Contact: chu.368@osu.edu\r\n"
				+ "Please type the Lisp Expression below\r\n"
				+ "*Plese read README files to know more details how to use this program\r\n"
				+ "--------------------------------------------------------------------------------");
	}
	public static void main(String[] args) throws IOException {
		printWelcome();
		Scanner scan = new Scanner(System.in);
		String line = new String();
		boolean print = false;
		tree = new Lisp_tree();
		primitive = new Lisp_primitive(tree.atoms);
		S_Exp fullSExp = new S_Exp(), result = new S_Exp();
		if (args.length>0 && args[0].compareTo("-debug") == 0)
		{
			debug = true;
			System.out.println("Debug mode is enabled, will execute clisp to compare results");
		}
		while (scan.hasNext()) {
			line = scan.nextLine();
			if (line.length() > 0) {
				if ( line.startsWith("$") ) {
					fullSExp = tree.getFullSExp();
					if (tree.islegal()) {
						result = primitive.eval(fullSExp);
						if (!primitive.getWarMsg().isEmpty())
							System.out.println(">**Warning: "+primitive.getWarMsg()+"**");
						if (primitive.getErrMsg().isEmpty()) {
							if (result.isAtom())
								System.out.println(">"+result.print());
							else
								System.out.println(">"+result.printList());
						}
						else
							System.out.println(">**Error:"+primitive.getErrMsg()+"**");
	
						primitive.clear();
					}  else if (!print && !tree.getError().isEmpty()) {
						System.out.println("**Error:"+tree.getError()+"**");
					}
					print = false;
					tree.clear();
					if (line.startsWith("$$")) {
						System.out.println("BYE!");
						break;
					}
				} else if (!tree.parse(line)) {
					System.out.println("**Error: "+tree.getError()+"**");
					tree.clear();
					print = true;
				}
			}
		}
		scan.close();
	}
}
