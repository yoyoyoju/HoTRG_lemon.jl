function makeTensorT{T}(factorW::Array{T,2}, measureOperator::Array{T,1} = ones(T, size(factorW,1)))
	leng = size(factorW,1)
	tensorT = zeros(T,leng,leng,leng,leng)
	for a = 1:leng, x = 1:leng, xp = 1:leng, y = 1:leng, yp = 1:leng
		tensorT[x,xp,y,yp] += measureOperator[a] * factorW[a,x] * factorW[a,xp] * factorW[a,y] * factorW[a,yp]
	end
	return tensorT
end

function makeTensorP{T}(factorW::Array{T,2})
	leng = size(factorW,1)
	tensorP = zeros(T,leng,leng,leng)
	for a = 1:leng, x = 1:leng, xp = 1:leng, s = 1:leng
		tensorP[x,xp,s] += factorW[a,x] * factorW[a,xp] * factorW[a,s]
	end
	return tensorP
end

function makeTensorQ{T}(factorW::Array{T,2})
	leng = size(factorW,1)
	tensorQ = zeros(T,leng,leng)
	for a = 1:leng, x = 1:leng, y = 1:leng
		tensorQ[x,y] += factorW[a,x] * factorW[a,y]
	end
	return tensorQ
end
