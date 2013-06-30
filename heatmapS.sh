#!/bin/bash

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
 		rowname, tab seperated. Colnames must be unique unless you
		know what you are doing.)${bldred}[NECESSARY]${txtrst}
	-t	Title of picture[${txtred}Default empty title${txtrst}]
		[Scatter plot of horizontal and vertical variable]
	-a	Display xtics. ${bldred}[Default TRUE]${txtrst}
	-A	Rotation angle for x-axis value(anti clockwise)
		${bldred}[Default 0]${txtrst}
	-l	The position of legend. [${bldred}
		Default right. Accept top,bottom,left,none,c(0.1,0.8).${txtrst}]
	-b	Display ytics. ${bldred}[Default FALSE]${txtrst}
	-L	First get log-value, then do other analysis.
		Accept an R function log2 or log10. You may want to add
		parameter to -J (scale_add) and -s (small). Every logged value
		less than -s will be assigned by -J.[Default -s is -Inf and -J
		is 1. Usually -s should be 0 and -J should be -1.] 
		${bldred}[Default FALSE]${txtrst}
	-K	Get log value before or after clustering.
		${bldred}[Default before, means before. Accept after means
		after]${txtrst}
	-u	The width of output picture.[${txtred}Default 2000${txtrst}]
	-v	The height of output picture.[${txtred}Default 2000${txtrst}] 
	-r	The resolution of output picture.[${txtred}Default NA${txtrst}]
	-x	The color for representing low value.[${txtred}Default dark
		green${txtrst}]
	-y	The color for representing high value.[${txtred}Default
		dark red${txtrst}]
	-M	The color representing mid-value.[${txtred}Default 
		yellow${txtrst}]
	-Z	Use mid-value or not. [${txtred}Default FALSE, which means
		do not use mid-value. ${txtrst}]
	-X	The mid use you want to use.[${txtred}Default median value. A
		number is ok.${txtrst}]
	-k	Would you like cluster.[${txtred}Default 1 which means no
		cluster, other positive interger is accepted for executing
		kmeans cluster, also the parameter represents the number of
		expected clusters.${txtrst}]
	-c	The cluster methods you want to use.[${bldred}kmeans, for
		distance cluster,
		accept clara for trend cluster.${txtrst}]
	-d	Scale the data or not for clustering.[Default no scale. Accept TRUE, scale by
		row]
	-n	Include cluster info.[Default TRUE, accept FALSE]
	-p	Delete rows all zero.[Default FALSE, accept TRUE]
	-z	Presort data by covariance coefficient.
		[Default FALSE, accept TRUE]
	-s	The smallest value you want to keep, any number smaller will
		be taken as 0.[${bldred}Default -Inf, Optional${txtrst}]  
	-m	The maximum value you want to keep, any number larger willl
		be taken as the given maximum value.
		[${bldred}Default Inf, Optional${txtrst}] 
	-q	The smallest screen and file output.[Default TRUE] 
		Accept FALSE, to output each operation and data files.
	-j	Scale data for picture.[Default FALSE, accept TRUE]
	-J	When -j is TRUE,  supply a value to add to all values in data
		to avoid zero. When -L is used, the supplied value will be
		used to substitute values less than -s generated log
		processing. However, this has no effection to final data.
	   	[${bldred}Default 1${txtrst}]
	-o	Log transfer ot not.[${bldred}Default no log transfer,
		accept log or log2 ${txtrst}]
	-g	Cluster by which group.[${bldred}Default by all group${txtrst}]
	-G	Use quantile for color distribution. Default 5 color scale
		for each quantile.[Default FALSE, accept TRUE. Suitable for data range
		vary large.]
	-C	Color list for plot when -G is TRUE.
		[${bldred}Default 'green','yellow','dark red'.
		Accept a list of colors each wrapped by '' and totally wrapped
		by "" ${txtrst}]
	-O	When -G is TRUE, using given data points as separtor to
		assign colors. [${bldred}Default -G default]
	-e	Execute or not[${bldred}Default TRUE${txtrst}]
	-i	Install the required packages[${bldred}Default FALSE${txtrst}]
EOF
}

file=''
title=''
width=''
label=''
logv='FALSE'
logv_pos='before'
kclu=1
clu='kmeans'
scale='FALSE'
clusterInclu='TRUE'
group=0
execute='TRUE'
ist='FALSE'
legend='FALSE'
legend_pos='right'
small="-Inf"
maximum="Inf"
log=''
uwid=2000
vhig=2000
res='NA'
scale_op='FALSE'
scale_add=1
xcol='dark green'
ycol='dark red'
mcol='yellow'
mid_value_use='FALSE'
mid_value='Inf'
xtics='TRUE'
xtics_angle=0
ytics='FALSE'
quiet='TRUE'
delZero='FALSE'
cvSort='FALSE'
gradient='FALSE'
givenSepartor=''
gradientC="'green','yellow','red'"

while getopts "hf:t:u:v:x:y:M:L:K:X:r:w:l:a:A:b:k:c:d:n:g:s:j:J:m:o:G:C:O:q:e:i:p:Z:z:" OPTION
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
		M)
			mcol=$OPTARG
			;;
		L)
			logv=$OPTARG
			;;
		K)
			logv_pos=$OPTARG
			;;
		Z)
			mid_value_use=$OPTARG
			;;
		X)
			mid_value=$OPTARG
			;;
		r)
			res=$OPTARG
			;;
		w)
			width=$OPTARG
			;;
		l)
			legend_pos=$OPTARG
			;;
		a)
			xtics=$OPTARG
			;;
		A)
			xtics_angle=$OPTARG
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
		d)
			scale=$OPTARG
			;;
		n)
			clusterInclu=$OPTARG
			;;
		g)
			group=$OPTARG
			;;
		p)
			delZero=$OPTARG
			;;
		z)
			cvSort=$OPTARG
			;;
		s)
			small=$OPTARG
			;;
		m)
			maximum=$OPTARG
			;;
		j)
			scale_op=$OPTARG
			;;
		J)
			scale_add=$OPTARG
			;;
		o)
			log=$OPTARG
			;;
		G)
			gradient=$OPTARG
			;;
		C)
			gradientC=$OPTARG
			;;
		O)
			givenSepartor=$OPTARG
			;;
		q)
			quiet=$OPTARG
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

midname=".heatmapS"

if [ -z $file ] ; then
	echo 1>&2 "Please give filename."
	usage
	exit 1
fi

if test $kclu -gt 1; then
	midname=${midname}".${clu}.$kclu.$group"
fi

if test "$log" != ''; then
	midname=${midname}".$log"
fi

if test "${scale}" == "TRUE"; then
	midname=${midname}".scale"
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
if($gradient){
	library(RColorBrewer)
}
if ($kclu > 1){
	library(cluster)
}
if (! $quiet){
	print("Read in data set.")
}
data <- read.table(file="$file", sep="\t", header=T, row.names=1,
	check.names=F)

#print("Read in label.")
#label is for group level
#label <- as.vector(read.table(file="$label", sep="\t", header=F)\$V1)
#dimD <- dim(data)
##size <- dimD[1] * $width
#size <- dimD[1] * ($width+1)
#print("Prepare group")
#grp <- rep(label, each=size)
#print("Rename each column to make each one uniqu")
#names(data) <- paste0(rep(label, each=$width), names(data))

if ("${logv_pos}" == "before" && "${logv}" != "FALSE"){
	if (! $quiet){
		print("${logv} data before clustering.")
	}
	data[data==1] <- 1.0001
	data <- ${logv}(data)
	data[data<${small}] = ${scale_add}
}

if ($kclu>1){

	if (! $quiet){
		print("Delete rows containing 0 only.")
	}
	data.zero <- data[rowSums(data)==0,]
	rowZero <- nrow(data.zero)
	data <- data[rowSums(data)!=0,]

	if (! $quiet){
		print("Prepare data for clustering.")
	}
	if ($small != "-Inf"){
		mindata <- $small
	}else{
		mindata <- min(data)
	}
	if ($maximum != "Inf"){
		maxdata <- $maximum
	}else{
		maxdata <- max(data)
	}
	step <- (maxdata-mindata)/$kclu
	if ($cvSort){
		if (! $quiet){
			print("Sort data by coefficient variance.")
		}
		sd <- apply(data, 1, sd) #1 means row, 2 means col
		mean <- rowMeans(data)
		cv <- sd/mean
		data <- data[order(cv),]
	}
	if ($group == 0){
		data.k <- data
	}
	else if ($group > 0){
		start = ($group-1) * $width + 1
		end = $group * $width
		data.k <- data[,start:end]
	}
	if ($scale){
		if (! $quiet){
			print("Scale data.")
		}
		data.k <- t(apply(data.k,1,scale))
	}
	if (! $quiet){
		print("Cluster data.")
	}
	if ("$clu" == "clara" ){
		data.d <- t(apply(data.k,1,diff))
		data.clara <- clara(data.d, $kclu)
		cluster_172 <- data.clara\$clustering
		#data.clara <- kmeans(data.d, $kclu, iter.max=1000)
		#cluster_172 <- data.clara\$cluster
		rm(data.d)
	}else
	if ("$clu" == 'kmeans'){
		set.seed(3)
		data.clara <- kmeans(data.k, $kclu, iter.max = 1000)
		cluster_172 <- data.clara\$cluster
	}
	tmp_cluster_172 <- mindata + (cluster_172-1) * step
	data.m1 <- cbind(cluster=cluster_172, rownames(data))[,1]
	if (! $quiet){
		print("Output clustered result")
		output <- paste("${file}${midname}", "cluster", sep='.')
		#data.m1 <- data.m1[order(cluster_172),]
		write.table(data.m1, file=output, sep="\t", quote=F, col.names=F)
		print("Sort data by cluster.")
	}
	if (${scale_op}){
		data <- data + ${scale_add}
		data.s <- as.data.frame(t(apply(data, 1, scale)))
		colnames(data.s) <- colnames(data)

		mindata <- min(data.s)
		maxdata <- max(data.s)
		step <- (maxdata-mindata)/$kclu
		tmp_cluster_172 <- mindata + (cluster_172-1) * step
		#---------------add cluster info-------------------
		if ($clusterInclu){
			data.s\$cluster <- tmp_cluster_172
		}
		#----------sort data by cluster-----this must be after add
		#-----cluster info-------------
		data.s <- data.s[order(cluster_172),]
		if (rowZero > 0){
			if (! $quiet) {
				print("Add rows which are all zero")
			}
			if ($clusterInclu){
				if (! $quiet) {
					print("Add cluster info for rows which are all zero")
				}
				newcluster <- mindata - step
				cluster_315_for_zero <- c(rep(newcluster, rowZero)) 
				data.zero\$cluster <- cluster_315_for_zero
			}
			data.s <- rbind(data.zero, data.s)
		}
		if (! $quiet){
			output <- paste("${file}${midname}", \
				"cluster.scaleop.final", sep='.')
			write.table(data.s, file=output, sep="\t", \
				quote=F, col.names=T)
		}
	}
	#--for output original data ---------------------------
	if ($clusterInclu){
		data\$cluster <- tmp_cluster_172
	}
	data <- data[order(cluster_172),]

	if (rowZero > 0){
		if (! $quiet) {
			print("Add rows which are all zero")
		}
		if ($clusterInclu){
			if (! $quiet) {
				print("Add cluster info for rows which are all zero")
			}
			newcluster <- mindata - step
			cluster_315_for_zero <- c(rep(newcluster, rowZero)) 
			data.zero\$cluster <- cluster_315_for_zero
		}
		data <- rbind(data.zero, data)
	}


	if (! $quiet){
		output <- paste("${file}${midname}", "cluster.final", sep='.')
		write.table(data, file=output, sep="\t", quote=F, col.names=T)
	}
	#--for output original data ---------------------------
	#--for use scaled data-----------------------------
	if ($scale_op){
		data <- data.s
	}
	rm(data.m1, data.k, data.clara)
	
}else{
	#---for raw data scale-----no cluster------------
	if ($scale_op){
		colname <- colnames(data)
		data <- as.data.frame(t(apply(data,1,scale)))
		colnames(data) <- colname
	}
}

if ("${logv_pos}" == "after" && "${logv}" != "FALSE"){
	if (! $quiet){
		print("${logv} data after clustering.")
	}
	data[data==1] <- 1.0001
	data <- ${logv}(data)
	data[data<${small}] = ${scale_add}
}

if (! $quiet){
	print("Melt data.")
}
#oriLen <- dimD[2]
data\$id <- rownames(data)
idlevel <- as.vector(rownames(data))
#data\$idsort <- data\$id[order(data\$cluster)]
#data\$idsort <- order(data\$idsort)
if (! $quiet){
	print("Reorganize data.")
}
#data.m <- melt(data, id.vars = c("id", "idsort"))
#---------------
#data.m <- melt(data, c("id"), names(data)[1:oriLen])
data.m <- melt(data, c("id"))
if (! $quiet){
	output2 <- paste("${file}${midname}", "cluster.melt", sep='.')
	write.table(data.m, file=output2, sep="\t" , quote=F,
	col.names=T, row.names=F)
}
data.m\$id <- factor(data.m\$id, levels=idlevel, ordered=T)

data.m\$value[data.m\$value < $small] <- 0

data.m\$value[data.m\$value > $maximum] <- $maximum

if (! $quiet){
	print("Prepare ggplot layers.")
}

p <- ggplot(data=data.m, aes(x=variable, y=id)) + \
geom_tile(aes(fill=value)) + xlab(NULL) + ylab(NULL)
#facet_grid( .~grp) 

if($gradient){
	gradientC <- c(${gradientC})
	summary_v <- summary(data.m\$value)
	break_v <- c($givenSepartor)
	if (length(break_v) < 3){
		break_v <- \
		unique(c(seq(summary_v[1]-0.00000001,summary_v[2],length=8),seq(summary_v[2],summary_v[3],length=13),seq(summary_v[3],summary_v[5],length=25),seq(summary_v[5],summary_v[6],length=40)))
	}
	
	data.m\$value <- cut(data.m\$value, breaks=break_v,\
		labels=break_v[2:length(break_v)])

	break_v=unique(data.m\$value)
	
	col <- colorRampPalette(gradientC)(length(break_v))
	print(col)
	print(break_v)
	#p <- p + scale_fill_gradientn(colours = c("$xcol", "$mcol","$ycol"), breaks=break_v, labels=format(break_v))
	p <- ggplot(data=data.m, aes(x=variable, y=id)) + \
	geom_tile(aes(fill=value)) + xlab(NULL) + ylab(NULL) + \
	scale_fill_manual(values=col)
	#scale_fill_brewer(palette="PRGn")
} else {
	if( "$log" == ''){
		if (${mid_value_use}){
			if (${mid_value} == Inf){
				midpoint = median(data.m\$value)
			}else {
				midpoint = ${mid_value}
			}
			p <- p + scale_fill_gradient2(low="$xcol", mid="$mcol",
				high="$ycol", midpoint=midpoint)
		}else {
			p <- p + scale_fill_gradient(low="$xcol", high="$ycol")
		}
	}else {
		p <- p + scale_fill_gradient(low="$xcol", high="$ycol",
		trans="$log", name="$log value", na.value="$xcol")
	}
} #end the else of gradient 

p <- p + theme(axis.ticks=element_blank()) + theme_bw() + 
	theme(legend.title=element_blank(),
	panel.grid.major = element_blank(), panel.grid.minor = element_blank())

if ("$xtics" == "FALSE"){
	p <- p + theme(axis.text.x=element_blank())
}else{
	if (${xtics_angle} != 0){
	p <- p + theme(axis.text.x=element_text(angle=${xtics_angle},hjust=1))
	}
}
if ("$ytics" == "FALSE"){
	p <- p + theme(axis.text.y=element_blank())
}

top='top'
botttom='bottom'
left='left'
right='right'
none='none'
legend_pos_par <- ${legend_pos}

#if ("${legend_pos}" != "right"){
p <- p + theme(legend.position=legend_pos_par)
#}

if (! $quiet){
	print("Begin plotting.")
}
png(filename="${file}${midname}.png", width=$uwid, height=$vhig,
res=$res)
p
dev.off()
END

if [ "$execute" == "TRUE" ]; then
	Rscript ${file}${midname}.r
fi

#if [ "$quiet" == "TRUE" ]; then
#	/bin/rm -f ${file}${midname}.r
#fi
#convert -density 200 -flatten ${file}${midname}.eps ${first}${midname}.png
