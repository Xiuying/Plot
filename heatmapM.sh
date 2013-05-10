#!/bin/bash

#----------------------test data--------------------------------
#-----------test.2.overlap:
#Name	a	b	c	a	b	c	a	b	c	a	b	c
#a	1.0	0.6	0.64	1.0	0.75	0.76	1.0	0.67	0.70	1.0	0.70	0.73
#b	0.55	1.0	0.58	0.65	1.0	0.70	0.55	1.0	0.60	0.64	1.0	0.68
#c	0.60	0.59	1.0	0.72	0.76	1.0	0.61	0.63	1.0	0.68	0.69	1.0

#-----------test.2.label:
#A
#B
#C
#D

#command
#heatmapM.sh -f test.2.overlap -w 3 -a TRUE -b TRUE -l test.2.label -u
#1000 -v 1000 -x green
#----------------------test data--------------------------------
#set -x

usage()
{
cat <<EOF
${txtcyn}
Usage:

$0 options${txtrst}

${bldblu}Function${txtrst}:

This script is used to do multiple heatmap horizontally for
comparing among samples using package ggplo2 and reshape2.
Also it can deal with kmeans cluster before heatmap.

The parameters for logical variable are either TRUE or FALSE.

${txtbld}OPTIONS${txtrst}:
	-f	Data file (with header line, the first column is the
 		colname, tab seperated)${bldred}[NECESSARY]${txtrst}
	-t	Title of picture[${txtred}Default empty title${txtrst}]
		[Scatter plot of horizontal and vertical variable]
	-w	The width of each group.${bldred}[NECESSARY]${txtrst}
	-a	Display xtics. ${bldred}[Default FALSE]${txtrst}
	-b	Display ytics. ${bldred}[Default FALSE]${txtrst}
	-p	Other legal R codes for gggplot2 will be given here.
		[${txtres}Begin with '+' ${txtrst}]
	-l	The name of each group saved in a file.${bldred}[NECESSARY, 
		one sample one line separated by tab, unique,
		the order must be the same as in data file]${txtrst}
	-L	The position of legend.
		[${bldred}Default right. Accept top,bottom,left,none,c(0.1,0.8) ${txtrst}]
	-S	Parameter for scale in facet_wrap.
		[${bldred}Default 'free_x'. Accept free,free_y,fixed.${txtrst}]
	-O	Keep original layout.[${bldred}Default FALSE, which means
		first row will be the block the bottomest, the last row will
		be the block the topest. Accept TRUE to retain the first line
		at top.${txtrst}]
	-n	Number of cols for facet_wrap.[${bldred}Default NULL, meaning
		distribution vertically. Accept a number.${txtrst}]
	-u	The width of output picture.[${txtred}Default 2000${txtrst}]
	-v	The height of output picture.[${txtred}Default 2000${txtrst}] 
	-r	The resolution of output picture.[${txtred}Default NA${txtrst}]
	-x	The color for representing low value.[${txtred}Default white${txtrst}]
	-y	The color for representing high value.[${txtred}Default
		red${txtrst}]
	-k	Would you like cluster.[${txtred}Default 1 which means no
		cluster, other positive interger is accepted for executing
		kmeans cluster, also the parameter represents the number of
		expected clusters.${txtrst}]
	-c	The cluster methods you want to use.[${bldred}kmeans, for
		distance cluster,
		accept clara for trend cluster.${txtrst}]
	-s	The smallest value you want to keep, any number smaller will
		be taken as 0.[${bldred}Default -Inf, Optional${txtrst}]  
	-m	The maximum value you want to keep, any number larger willl
		beforebe taken as the given maximum value.
		[${bldred}Default Inf, Optional${txtrst}] 
	-o	Log transfer ot not.[${bldred}Default no log transfer,
		accept log or log2 ${txtrst}]
	-g	Cluster by which group.[${bldred}Default by all group${txtrst}]
	-e	Execute or not[${bldred}Default TRUE${txtrst}]
	-i	Install the required packages[${bldred}Default FALSE${txtrst}]
EOF
}

file=''
title=''
width=''
label=''
kclu=1
clu='kmeans'
group=0
execute='TRUE'
ist='FALSE'
legend='FALSE'
small="-Inf"
maximum="Inf"
log=''
uwid=2000
vhig=2000
res='NA'
xcol='white'
ycol='red'
xtics='FALSE'
ytics='FALSE'
legend_pos='right'
ncol='NULL'
scale='free_x'
par=''
rev_latout='FALSE'

while getopts "hf:t:u:v:x:y:r:w:l:O:S:p:n:L:a:b:k:c:g:s:m:o:e:i:" OPTION
do
	case $OPTION in
		h)
			echo "Help mesage"
			usage
			exit 1
			;;
		f)
			file=$OPTARG
			;;
		t)
			title=$OPTARG
			;;
		u)
			uwid=$OPTARG
			;;
		v)
			vhig=$OPTARG
			;;
		x)
			xcol=$OPTARG
			;;
		y)
			ycol=$OPTARG
			;;
		r)
			res=$OPTARG
			;;
		w)
			width=$OPTARG
			;;
		l)
			label=$OPTARG
			;;
		O)
			rev_latout=$OPTARG
			;;
		p)
			par=$OPTARG
			;;
		S)
			scale=$OPTARG
			;;
		L)
			legend_pos=$OPTARG
			;;
		n)
			ncol=$OPTARG
			;;
		a)
			xtics=$OPTARG
			;;
		b)
			ytics=$OPTARG
			;;
		k)
			kclu=$OPTARG
			;;
		c)
			clu=$OPTARG
			;;
		g)
			group=$OPTARG
			;;
		s)
			small=$OPTARG
			;;
		m)
			maximum=$OPTARG
			;;
		o)
			log=$OPTARG
			;;
		e)
			execute=$OPTARG
			;;
		i)
			ist=$OPTARG
			;;
		?)
			usage
			echo "Unknown parameters"
			exit 1
			;;
	esac
done

midname=".heatmapM"

if [ -z $file ] || [ -z $width ] || [ -z $label ]; then
	echo 1>&2 "Please give filename, width of each group and label for
	each group."
	usage
	exit 1
fi

if test $kclu -gt 1; then
	midname=${midname}".${clu}.$kclu.$group"
fi

if test "$log" != ''; then
	midname=${midname}".$log"
fi

cat <<END >${file}${midname}.r

if ($ist){
	install.packages("ggplot2", repo="http://cran.us.r-project.org")
	install.packages("reshape2", repo="http://cran.us.r-project.org")
	if ($kclu > 1){
		install.packages("cluster", repo="http://cran.us.r-project.org")
	}
}
library(ggplot2)
library(reshape2)
library(grid)

if ($kclu > 1){
	library(cluster)
}
print("Read in data set.")
data <- read.table(file="$file", sep="\t", header=T, row.names=1,
check.names=F)
print("Read in label.")
#label is for group level
label <- as.vector(read.table(file="$label", sep="\t", header=F)\$V1)
dimD <- dim(data)
size <- dimD[1] * $width
print("Prepare group")
grp <- rep(label, each=size)
print("Rename each column to make each one uniqu")
names(data) <- paste0(rep(label, each=$width), names(data))


if (${rev_latout}){
	rev_c <- rev(rownames(data))
	data <- data[rev_c,]
}

if ($kclu>1){
	print("Prepare data for clustering.")
	if ($group == 0){
		data.k <- data
	}
	else if ($group > 0){
		start = ($group-1) * $width + 1
		end = $group * $width
		data.k <- data[,start:end]
	}
	data.k <- t(apply(data,1,scale))
	print("Cluster data.")
	if ("$clu" == "clara" ){
		data.d <- t(apply(data.k,1,diff))
		data.clara <- clara(data.d, $kclu)
		cluster_172 <- data.clara\$clustering
		rm(data.d)
	}else
	if ("$clu" == 'kmeans'){
		data.clara <- kmeans(data.k, $kclu, iter.max = 1000)
		cluster_172 <- data.clara\$cluster
	}
	data.m1 <- cbind(cluster=cluster_172, rownames(data))[,1]
	print("Output clustered result")
	output <- paste("${file}${midname}", "cluster", sep='.')
	write.table(data.m1, file=output, sep="\t", quote=F, col.names=F)
	print("Group data by cluster.")
	data <- data[order(cluster_172),]
	rm(data.m1, data.k, data.clara)
}


idlevel <- as.vector(rownames(data))
print("Melt data.")
oriLen <- dimD[2]
data\$id <- rownames(data)
data.m <- melt(data, c("id"), names(data)[1:oriLen])
print("Add grp for data.")
data.m\$grp <- grp
print("Factor grp for data")
data.m\$grp <- factor(data.m\$grp, levels=label, ordered=T)
data.m\$id <- factor(data.m\$id, levels=idlevel, ordered=T)
print("Reorganize data.")
data.m <- subset(data.m, select=c(grp, id, variable, value))
#write.table(data.m, file="test161", sep="\t", quote=F, col.names=T)

data.m\$value[data.m\$value < $small] <- 0

data.m\$value[data.m\$value > $maximum] <- $maximum


print("Prepare ggplot layers.")
p <- ggplot(data=data.m, aes(variable, id)) + \
geom_tile(aes(fill=value)) + \
facet_wrap( ~grp, scale="${scale}", ncol=${ncol}) + xlab(NULL) + ylab(NULL)


if( "$log" == ''){
	p <- p + scale_fill_gradient(low="$xcol", high="$ycol")
}else {
	p <- p + scale_fill_gradient(low="$xcol", high="$ycol",
	trans="$log", name="$log value", na.value="$xcol")
}


p <- p + theme(axis.ticks=element_blank()) + theme_bw() + 
	theme(legend.title=element_blank(),
	panel.grid.major = element_blank(), panel.grid.minor = element_blank())

if ("$xtics" == "FALSE"){
	p <- p + theme(axis.text.x=element_blank())
}
if ("$ytics" == "FALSE"){
	p <- p + theme(axis.text.y=element_blank())
}


top='top'
bottom='bottom'
left='left'
right='right'
none='none'
legend_pos_par <- ${legend_pos}
p <- p + theme(legend.position=legend_pos_par)

print("Begin plotting.")
png(filename="${file}${midname}.png", width=$uwid, height=$vhig,
res=$res)
p${par}
dev.off()
END

if [ "$execute" == "TRUE" ]; then
	Rscript ${file}${midname}.r
fi

#convert -density 200 -flatten ${file}${midname}.eps ${first}${midname}.png
