# Please specify the location of Java compiler
JAVAC = /class/software/local/jdk1.7.0_72/bin/javac
JAR = /class/software/local/jdk1.7.0_72/bin/jar

# Java compiler flags
JAVAFLAGS =
.SUFFIXES: .java .class
.java.class:
	$(JAVAC) $(JAVAFLAGS) ProdCons/*.java Resources/*.java

CLASSES = *.java

default: classes

classes: $(CLASSES:.java=.class)
	ProdCons/Restaurant.class
install: classes 
	$(JAR) cvfe Restaurant.jar ProdCons/Restaurant Resources/*.class Consumer/*.class
clean:
	$(RM) *.class *.jar
run:
	/class/software/local/jdk1.7.0_72/bin/java -jar Restaurant.jar
