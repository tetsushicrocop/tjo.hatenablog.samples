function [out,yvec]=tjo_predict_bias(wvec,xvec)

% 単に識別関数 y = w'xを計算しているだけです。
% outはyの値を正規化しただけです。

yvec=dot(wvec,xvec); % dot関数（内積計算）を使っています。即ちwvec'*xvecです。

out=sign(yvec); % sign関数を使っています。いわゆるsgn(x)です。

end