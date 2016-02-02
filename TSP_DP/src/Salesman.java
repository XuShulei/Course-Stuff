/* Author: Ching-Hsiang Chu
 * Contact: chu.368@osu.edu
 * Last Updated: 2015-03-04 23:20
 * This program is written for the OSU CSE 6331-Algorithm Homework 6 - Traveling Salesman Problem
 * The solution is based on the bottom-up Dynamic Programming approach discussed in the class.
 * */

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Scanner;

public class Salesman {
	/* 2D HashMap to store the information of minimum path and length from a vertex to a subgraph(mask) 
	 * For example [0][{011},{2,10} means the minimum length from vertex 0 to the subgraph {1,2} is 10 and walk through vertex 2*/
	private static HashMap<Integer, HashMap<mask, lengthEntry> > length;
	private static graph g;	//Default (input) graph, please see the description in the graph class for more details
	
	static class lengthEntry {
		/* To store the minimum length and path in the length table
		 * This class only contains the vertex to use to reach a subgraph with the minimum length
		 * */
		private int v;		//The vertex id 
		private int length;	//The minimum length
		/* following are basic constructors and functions to set/get the value of v and length */
		public lengthEntry() {}
		public lengthEntry(int v, int l) {
			this.v = v;
			this.length = l;
		}
		public void setVertex(int in) {
			v = in;
		}
		public void setLength(int in) {
			length = in;
		}
		public int getVertex() {
			return (int)v;
		}
		public int getLength() {
			return (int)length;
		}
	}
	static class mask {
		/* In order to save memory space from store multiple subgraph (note that every vertex has an array to store distant to every other vertices)
		 * we use a bit array to represent a subgraph of given graph (the global one)
		 * if the corresponding bit of a vertex is 1 (true) means it is active/used, 0(false) means it is inactive
		 * For example, if the maskBit={1,0,0,1} represents the subgraph {0,3} from the default graph
		 * */
		private boolean maskBit[];
		private int size;
		private mask (int n) {
			maskBit = new boolean[n];
			size=n;
		}
		public mask (boolean in[]) {
			maskBit = in;
			size=in.length;
		}
		public mask (mask in) {
			maskBit = new boolean[in.size()];
			this.copy(in);
		}
		/* for HashMap to create a hash code to check if two masks are equivalent or not*/
		@Override
		public int hashCode() {
			int out=0;
			for (int i=0 ; i<size ; i++) {
				if (maskBit[i]) {
					out += Math.pow(2, i);
				}
			}
	        return out;
	    }
		/* for HashMap to check if two masks are equivalent or not
		 * if maskBit arrays can be perfectly matched, then two mask represent same subgraph
		 * This is important when we update/fetch the length table*/
		@Override
		public boolean equals(Object obj) {
			mask in = (mask) obj;
			int i;
			for (i=0 ; i<size && maskBit[i]==in.get(i) ;i++) {}
			
			return (i==size)?true:false;
		}
		/* Copy maskBit from another subgraph m to this subgraph */
		public void copy(mask m) {
			boolean in[] = m.getAll();
			size = m.size();
			for (int i=0 ; i<size ;i++) {
				maskBit[i] = in[i];
			}
		}
		/* Set all bits to 0 or 1, easy for creating default graph or empty subgraph*/
		public void setAll(boolean in){
			for (int i=0 ; i<size ;i++) {
				maskBit[i] = in;
			}
		}
		/* Get specified bit to see the vertex is now active or not */
		public boolean get(int index) {
			return maskBit[index];
		}
		/* Get maskBit, easy for copying between masks */
		public boolean[] getAll(){
			return this.maskBit;
		}
		public int size() {
			return this.size;
		}
		/* mark a bit to 0, meaning turn the vertex into inactive */
		public void masking(int index) {
			maskBit[index] = false;
		}
		/* mask the subgraph based on the given subgraph, for example, to create the subgraph V-W*/
		public void masking(mask m) {
			boolean src[]=m.getAll();
			for (int i=1 ; i<size ;i++) {
				if (src[i])
					maskBit[i] = false;
			}
		}
		/* return true if there is a non-duplicate subgraph, meanwhile also create the subgraph, 
		 * otherwise, return false */
		public boolean nextSubgraph(int size) {
			int p=0, cnt=0;
			boolean incr=false, hasMoreSubgraph=false;
			while (cnt!=size && cnt < (this.size-1 )) {
				/* We treat the mask table as a binary number, then increase it by 1 in every iteration.
				 * If the number of 1-bit (true in mask table) is the "size" we required, then pick those vertices as a new subgraph.
				 * It won't produce duplicate sets because we keep increasing it and only reset the maskBit when all possible combinations is tested (all true in mask table) 
				 * */
				cnt=0;
				maskBit[1] = !maskBit[1]; // Increase by 1 for first bit
				incr = (maskBit[1])?false:true; // if false (0) after increment, meaning next bit needs to be increased by one as well
				if (incr) {
					/* Same increment process for all bits */
					for (p=2 ; p < this.size && incr ; p++) {
							maskBit[p] = !maskBit[p]; // Increase by 1 for first bit
							incr = (maskBit[p])?false:true; // if true, means next bit needs to be increased as well
					}
				}
				/* If it still indicates we need to increase after whole increment process, then we know it must reach the maximum value => all bits are one 
				 * This case implies we already output all possible combinations of subgraph for the given size
				 * So we could break the loop, then reset the maskBit */
				if (incr) {
					break;
				}
				for (p=1 ; p < this.size; p++) {
					if (maskBit[p])
						cnt++;
				}
			}
			/* return true if a new match with given size is found */
			if (cnt == size)
				hasMoreSubgraph=true;
			/* If we run out of all combinations for this size, reset the maskBit for next call */
			if (cnt == (this.size-1) && size < (this.size-1) ) {
					this.setAll(false);;		
					hasMoreSubgraph=false;
			}
			return hasMoreSubgraph;
		}
		/* Only for debug */
		public void print() {
			System.out.print("maskBit: ");
			for (int i=0 ; i<size ; i++) {
				System.out.print((maskBit[i]?"1":0)+" ");
			}
			System.out.println("");
		}
	}
	static class vertex {
		/* A vertex contains a unique id and a distant array to represent distant to all other vertices in the default global graph */
		private int id;
		private int distant[];
		/* following are basic constructors and functions to set/get the value of id and distant */
		public vertex (int id, int n) {
			this.id  = id;
			distant = new int[n];
		}
		public void setVertex (int id, int d[]) {
			this.id  = id;
			distant = d;
		}
		public void insertEdge (int v, int dist) {
			distant[v]=dist;
		}
		public int getDistant(int v) {
			return distant[v];
		}
		public int getId() {
			return id;
		}
	}
	static class graph {
		/* A graph with vertex, distant information is stored inside vertex
		 * */
		private int curPos; // current position to insert new vertex if needed
		private vertex v[];
		public graph (int n){
			v = new vertex[n];
			/* Allocate memory space, but not yet insert any specific information to those vertices */
			for (int i=0 ; i<n ; i++) {
				v[i] = new vertex(i,n);
			}
			curPos=0;
		}
		public void insertVertex(int id, int dist[]) {
			v[curPos].setVertex(id, dist);
			curPos++;
		}
		public int getDistant(int src, int dest) {
			return v[src].getDistant(dest);
		}
		/* For Debug only*/
		public void printGraph() {
			for (int i=0 ; i<v.length ; i++) {
				System.out.print(v[i].getId()+" ");
			}
			System.out.println();
		}
	}	
	/* This function is used to compute minimum length from a vertex v to the subgraph w 
	 * This is basic computing min{dist(v,v1), length() v1,W-{v1}} where v1 is a vertex in w */
	public static lengthEntry minLength (int v, mask w) {
		int min = -1, minV=0, tmp; // -1 represent infinite number for min length, minV is used to record how to reach that subgraph with minimum length
		lengthEntry le = new lengthEntry();
		int size = w.size();
		mask tm = new mask(size); 	//temporary mask during following computations to represent the subgraph w-{v1}
		for (int i=0 ; i<size ; i++) {  //i is the v1 in our algorithm
			/* Check each vertex in w to find one with minimum dist(v,i)+length(i,w-{i}) */
			if (w.get(i)) {
				/* Create subgraph w-{v1} */
				tm.copy(w);
				tm.masking(i);
				/* get dist(v,i)+length(i,w-{i}) */
				tmp = g.getDistant(v, i)+length.get(i).get(tm).getLength();
				/* Update minimum information if smaller one is found */
				if (tmp < min || min == -1) {
					min = tmp;
					minV = i;
				}
			}
		}
		/* Update length entry based on previous computation result */
		le.setVertex(minV);
		le.setLength(min);
		return le;
	}
	public static void main(String[] args) throws IOException {
		File input = new File("input.txt");
		if (!input.exists()) {
			System.out.println("No input file can be found");
			return;
		}
		/* Read input, build basic graph */
		Scanner scan = new Scanner(input);
		int n, cnt=0; 			//n: number of vertices in the graph
		/* Read first line to get n */
		if (scan.hasNext()) {
			n = scan.nextInt();
		} else {
			System.out.println("Empty input");
			scan.close();
			return;
		}
		g = new graph(n);
		/* Read each line in the input to get the distance from vertices to vertices */
		while (cnt<n) {
			int i, d[]= new int[n];
			for (i=0 ; i<n && scan.hasNext() ; i++) {
				d[i] = scan.nextInt();
			}
			/* Stop running if the input file dose not contain enough (or correct) information 
			 * The distant from a vertex to itself must be zero*/
			if ( i < n || (d[cnt] != 0 ) )
				break;
			g.insertVertex(cnt,d);
			cnt++;
		}
		scan.close();
		if (cnt != n) {
			System.out.println("Problematic input: unable to create an correct undirected graph");
			return;
		}
		/* DP part: For simplicity, always start from vertex 0
		 * n*n table to store the results (length) for DP, we apply bottom-up approach 
		 * We use a 2D HashMap, which is a global variable defined in the beginning of this class, to relate each vertex and length and path of possible subgraphs 
		 * We apply mask concept on the graph to represent different subgraphs, please see the description in the mask class above for more details */
		length=new HashMap<Integer, HashMap<mask, lengthEntry > > ();
		/* Initialize the length table */
		mask zm = new mask(n);	// Create an empty graph, mask bits are all 0's
		zm.setAll(false);	
		for (int i=0 ; i<n ; i++) {
			HashMap<mask, lengthEntry> z = new HashMap<mask, lengthEntry>();  	//HashMap with an empty mask for base value of DP
			z.put(zm, new lengthEntry(0, g.getDistant(0, i)));					//length from a vertex to the empty subgraph is dist(s, v) 
			length.put(i, z);		// put vale into the length table
		}
		mask dm = new mask(n);	//Create a default undirected graph G={V,E,W}, mask bits are all 1's
		dm.setAll(true);
		for (int i=1 ; i<n ; i++) {
			/* a new graph is used during the DP process since we have to test 
			 * each possible subset of graph to find optimal one (minimum length) */
			mask w = new mask(zm);	//Start from an empty subgraph
			// w belong to V-{s} s.t. |w|=i
			while (w.nextSubgraph(i)) {		
				mask new_mask = new mask(dm);		//new_mask represents vertices belong to V-W
				new_mask.masking(w);
				for (int j=0 ; j<n ; j++) {
					/* update the length table where vertices belong to V-W, bit 1 in the new_mask */
					if (new_mask.get(j)) {
						/* length(v,w) = min{dist(v,v1), length() v1,W-{v1}} where v1 is a vertex in w
						 * j is corresponding to the vertex v, which is a vertex in V-W
						 * new mask(w): create a new entry in the length table to be referred to in the future 
						 * minLength (w,j) return the value of min{dist(v,v1), length() v1,W-{v1}} where v1 is a vertex in w */
						length.get(j).put(new mask(w), minLength (j,w));
					}
				}
			}
		}
		// Trace back and output result
		File output = new File("output.txt");
		FileWriter wo = new FileWriter(output);
		if (output.canWrite()) {
			boolean notTraced = true;
			int traceV = 0;
			while (notTraced) {
				wo.write((traceV+1)+" ");	//plus 1 because in the program we always counting from zero
				dm.masking(traceV);			//mask the target vertex in the subgraph to trace down the tour with minimum length to reach remain vertices
				traceV = length.get(traceV).get(dm).getVertex();	//Fetch the vertex in the remaining subgraph where can be reached in minimum length
				if (traceV == 0)
					notTraced = false;
			}
			dm.setAll(true);	//default graph, all bits are 1
			dm.masking(0);		//mask starting vertex
			wo.write("\r\n"+length.get(0).get(dm).getLength()+"\r\n");	// The minimum length of tour is length(S, V-{s})
		}
		wo.close();
	}

}
