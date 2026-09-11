# **B o b C o l l e c t i v e**

S e c u r i t y A s s e s s m e n t


M a r c h 3 0 t h, 2 0 2 4 - P r e p a r e d b y O t t e r S e c


N i c h - l a s R . P u t r a n i c h - l a s [@](mailto:nicholas@osec.io) - s e c . i 

R - b e r t C h e n n - t d e g h - s t @ - s e c . i 

M a t t e - O l i v a m a t t @ [o](mailto:matt@osec.io) s e c . i 

**T** **a** **b** **l** **e** **o** **f** **C** **o** **n** **t** **e** **n** **t** **s**


**E** **x** **e** **c** **u** **t** **i** **v** **e** **S** **u** **m** **m** **a** **r** **y** **2**


O v e r v i e w 2


K e y F i n d i n g s 2


S c    - p e 2


**F** **i** **n** **d** **i** **n** **g** **s** **3**


**G** **e** **n** **e** **r** **a** **l** **F** **i** **n** **d** **i** **n** **g** **s** **4**


O S    - B O B    - S U G    - 0 0 | I n c    - n s i s t e n c y I n A d d r e s s F l e x i b i l i t y 5


O S    - B O B    - S U G    - 0 1 | G a s L i m i t C l a r i f i c a t i    - n 6


**A** **p** **p** **e** **n** **d** **i** **c** **e** **s**


**V** **u** **l** **n** **e** **r** **a** **b** **i** **l** **i** **t** **y** **R** **a** **t** **i** **n** **g** **S** **c** **a** **l** **e** **7**


**P** **r** **o** **c** **e** **d** **u** **r** **e** **8**


© 2 0 2 4 O t t e r A u d i t s L L C . A l l R i g h t s R e s e r v e d . 1 / 8


**0** **1** **—** **E** **x** **e** **c** **u** **t** **i** **v** **e** **S** **u** **m** **m** **a** **r** **y**

# Overview


B - b C - l l e c t i v e e n g a g e d O t t e r S e c t - a s s e s s t h e **<u><mark>`fusion-lock`</mark></u>** p r - g r a m . T h i s a s s e s s m e n t w a s c - n d u c t e d


b e t w e e n M a r c h 1 8 t h a n d M a r c h 2 2 n d, 2 0 2 4 . F - r m - r e i n f - r m a t i - n - n - u r a u d i t i n g m e t h - d - l - g y, r e f e r t 

A p p e n d i x B .

# Key Findings


W e p r - d u c e d 2 f i n d i n g s t h r - u g h - u t t h i s a u d i t e n g a g e m e n t .


W e r e c - m m e n d e d a d d r e s s i n g t h e i n a d e q u a t e f l e x i b i l i t y i n b r i d g e a d d r e s s c - n f i g u r a t i - n ( O S - B O B - S U G - 0 0 )


a n d a d v i s e d c l a r i f y i n g i n t h e c - m m e n t t h a t t h e g a s l i m i t p a r a m e t e r a p p l i e s t - e a c h w i t h d r a w a l i n d i v i d u a l l y,


n - t t - a l l w i t h d r a w a l s c - m b i n e d . T h i s c l a r i f i c a t i - n w - u l d h e l p a v - i d u s e r c - n f u s i - n . ( O S - B O B - S U G - 0 1 ) .

# Scope


T h e s - u r c e c - d e w a s d e l i v e r e d t - u s i n a G i t r e p - s i t - r y a t h t t p s : / / g i t h u b . c - m / b - b - c - l l e c t i v e / f u s i - n - l - c k .


T h i s a u d i t w a s p e r f - r m e d a g a i n s t c - m m i t e 4 f 2 5 e e .


**A** **b** **r** **i** **e** **f** **d** **e** **s** **c** **r** **i** **p** **t** **i** **o** **n** **o** **f** **t** **h** **e** **p** **r** **o** **g** **r** **a** **m** **s** **i** **s** **a** **s** **f** **o** **l** **l** **o** **w** **s** **:**


**N** **a** **m** **e** **D** **e** **s** **c** **r** **i** **p** **t** **i** **o** **n**


F a c i l i t a t e s t h e m a n a g e m e n t                                    - f t                                    - k e n d e p                                    - s i t s a n d w i t h d r a w a l s a c r                                    - s s



f u s i - n - l - c k



v a r i - u s b l - c k c h a i n l a y e r s, e n s u r i n g u s e r s m a i n t a i n a c c e s s t - t h e i r f u n d s


w h i l e f - s t e r i n g i n t e r - p e r a b i l i t y b e t w e e n t h e m .



© 2 0 2 4 O t t e r A u d i t s L L C . A l l R i g h t s R e s e r v e d . 2 / 8


**0** **2** **—** **F** **i** **n** **d** **i** **n** **g** **s**


O v e r a l l, w e r e p - r t e d 2 f i n d i n g s .


W e s p l i t t h e f i n d i n g s i n t - **v** **u** **l** **n** **e** **r** **a** **b** **i** **l** **i** **t** **i** **e** **s** a n d **g** **e** **n** **e** **r** **a** **l** **f** **i** **n** **d** **i** **n** **g** **s** . V u l n e r a b i l i t i e s h a v e a n i m m e d i a t e i m p a c t


a n d s h - u l d b e r e m e d i a t e d a s s - - n a s p - s s i b l e . G e n e r a l f i n d i n g s d - n - t h a v e a n i m m e d i a t e i m p a c t b u t w i l l


a i d i n m i t i g a t i n g f u t u r e v u l n e r a b i l i t i e s .


**S** **e** **v** **e** **r** **i** **t** **y** **C** **o** **u** **n** **t**


**C** **R** **I** **T** **I** **C** **A** **L** 0


**H** **I** **G** **H** 0


**M** **E** **D** **I** **U** **M** 0


**L** **O** **W** 0


**I** **N** **F** **O** 2


© 2 0 2 4 O t t e r A u d i t s L L C . A l l R i g h t s R e s e r v e d . 3 / 8


**0** **3** **—** **G** **e** **n** **e** **r** **a** **l** **F** **i** **n** **d** **i** **n** **g** **s**


H e r e, w e p r e s e n t a d i s c u s s i - n - f g e n e r a l f i n d i n g s d u r i n g - u r a u d i t . W h i l e t h e s e f i n d i n g s d - n - t p r e s e n t a n


i m m e d i a t e s e c u r i t y i m p a c t, t h e y r e p r e s e n t a n t i - p a t t e r n s a n d m a y r e s u l t i n s e c u r i t y i s s u e s i n t h e f u t u r e .


**I** **D** **D** **e** **s** **c** **r** **i** **p** **t** **i** **o** **n**


O S    - B O B    - S U G    - 0 0 T h e f l e x i b i l i t y i n b r i d g e a d d r e s s c    - n f i g u r a t i    - n w i t h i n **<u><mark>`FusionLock`</mark></u>** i s i n s u f f i c i e n t .


S p e c i f y i n **`withdrawSingleDepositToL2`** t h a t t h e **<u><mark>`minGasLimit`</mark></u>** p a r a m e t e r

O S    - B O B    - S U G    - 0 1


a p p l i e s t                                      - e a c h w i t h d r a w a l i n d i v i d u a l l y .


© 2 0 2 4 O t t e r A u d i t s L L C . A l l R i g h t s R e s e r v e d . 4 / 8


B - b C - l l e c t i v e A u d i t 0 3 - G e n e r a l F i n d i n g s


**I** **n** **c** **o** **n** **s** **i** **s** **t** **e** **n** **c** **y** **I** **n** **A** **d** **d** **r** **e** **s** **s** **F** **l** **e** **x** **i** **b** **i** **l** **i** **t** **y** O S - B O B - S U G - 0 0


**D** **e** **s** **c** **r** **i** **p** **t** **i** **o** **n**


I n **<u><mark>`FusionLock`</mark></u>**, **<u><mark>`l2TokenAddress`</mark></u>** d e n - t e s t h e a d d r e s s - f t h e c - r r e s p - n d i n g t - k e n - n l a y e r t w - . T h i s


a d d r e s s m a y b e m - d i f i e d d y n a m i c a l l y a t a n y p - i n t, f a c i l i t a t i n g u p d a t e s t - a c c - m m - d a t e a l t e r a t i - n s i n t h e


t - k e n c - n t r a c t - n l a y e r t w - . T h i s f l e x i b i l i t y e m p - w e r s t h e c - n t r a c t - w n e r t - a d a p t t - k e n m a p p i n g s a s


n e c e s s a r y, g u a r a n t e e i n g c - m p a t i b i l i t y w i t h a n y u p g r a d e s - r m i g r a t i - n s - f t - k e n c - n t r a c t s - n t h e l a y e r


t w - n e t w - r k .


_>_ ___ _F_ _u_ _s_ _i_ _o_ _n_ _L_ _o_ _c_ _k_ _._ _s_ _o_ _l_ s    - l i d i t y

```
  function changeMultipleL2TokenAddresses(TokenAddressPair[] memory tokenPairs) external onlyOwner
```

_�→_ `{`
```
    for (uint256 i = 0; i < tokenPairs.length; i++) {
      TokenAddressPair memory pair = tokenPairs[i];
      // Ensure the token is allowed for deposit before changing its L2 address
      require(allowedTokens[pair.l1TokenAddress].isAllowed, "Need to allow token before
```

_�→_ `changingL2` `address");`
```
      // Update the L2 address of the token
      allowedTokens[pair.l1TokenAddress].l2TokenAddress = pair.l2TokenAddress;
      emit TokenL2DepositAddressChange(pair.l1TokenAddress, pair.l2TokenAddress);
    }
  }

```

C - n v e r s e l y, **<u><mark>`l1BridgeAddressOverride`</mark></u>** s e r v e s a s a n - p t i - n a l - v e r r i d e a d d r e s s f - r t h e b r i d g e c - n t r a c t


u s e d w h e n b r i d g i n g t - k e n s t - l a y e r t w - . H - w e v e r, - n c e s e t, t h i s a d d r e s s c a n n - t b e m - d i f i e d d u r i n g t h e


w i t h d r a w a l p e r i - d, r e m a i n i n g s t a t i c u n t i l t h e w i t h d r a w a l p e r i - d c - n c l u d e s . T h i s l a c k - f f l e x i b i l i t y r e s t r i c t s


t h e c - n t r a c t - w n e r ’s a b i l i t y t - a d a p t t - c h a n g e s i n b r i d g e c - n t r a c t s - r t r a n s i t i - n t - a l t e r n a t i v e b r i d g e


i m p l e m e n t a t i - n s i f n e c e s s a r y .


**R** **e** **m** **e** **d** **i** **a** **t** **i** **o** **n**


A l l - w t h e **<u><mark>`l1BridgeAddressOverride`</mark></u>** f i e l d t - b e c h a n g e d d u r i n g t h e w i t h d r a w a l p e r i - d, m i r r - r i n g t h e

b e h a v i - r - f **<u><mark>`l2TokenAddress`</mark></u>** .


**P** **a** **t** **c** **h**


F i x e d i n d a 3 5 9 0 3 .


© 2 0 2 4 O t t e r A u d i t s L L C . A l l R i g h t s R e s e r v e d . 5 / 8


B - b C - l l e c t i v e A u d i t 0 3 - G e n e r a l F i n d i n g s


**G** **a** **s** **L** **i** **m** **i** **t** **C** **l** **a** **r** **i** **f** **i** **c** **a** **t** **i** **o** **n** O S - B O B - S U G - 0 1


**D** **e** **s** **c** **r** **i** **p** **t** **i** **o** **n**


I n t h e N a t S p e c f - r **<u><mark>`withdrawSingleDepositToL2`</mark></u>**, t h e c - m m e n t r e g a r d i n g **<u><mark>`minGasLimit`</mark></u>** s h - u l d


c l a r i f y t h a t t h i s p a r a m e t e r s e t s t h e m i n i m u m g a s l i m i t f - r e a c h w i t h d r a w a l t r a n s a c t i - n . T h i s e n s u r e s t h a t


e v e r y w i t h d r a w a l h a s s u f f i c i e n t g a s t - e x e c u t e i n d e p e n d e n t l y . U s e r s m u s t u n d e r s t a n d t h a t t h e g a s l i m i t i s


s p e c i f i c t - e a c h w i t h d r a w a l r a t h e r t h a n b e i n g s h a r e d a m - n g m u l t i p l e w i t h d r a w a l s .


_>_ ___ _F_ _u_ _s_ _i_ _o_ _n_ _L_ _o_ _c_ _k_ _._ _s_ _o_ _l_ s    - l i d i t y

```
  /**
  * @dev Internal function to withdraw tokens to Layer 2.
  * @param token Address of the token to withdraw.
  * @param minGasLimit Minimum gas limit for the withdrawal transaction.
  * @param receiver The receiver of the funds on L2.
  */
  function withdrawSingleDepositToL2(address token, uint32 minGasLimit, address receiver) internal
```

_�→_ `{`
```
    [...]
  }

```

**R** **e** **m** **e** **d** **i** **a** **t** **i** **o** **n**


M - d i f y t h e c - m m e n t f - r **<u><mark>`minGasLimit`</mark></u>** a s d e s c r i b e d a b - v e .


**P** **a** **t** **c** **h**


F i x e d i n 2 d b 4 2 b b .


© 2 0 2 4 O t t e r A u d i t s L L C . A l l R i g h t s R e s e r v e d . 6 / 8


**A** **—** **V** **u** **l** **n** **e** **r** **a** **b** **i** **l** **i** **t** **y** **R** **a** **t** **i** **n** **g** **S** **c** **a** **l** **e**


W e r a t e d - u r f i n d i n g s a c c - r d i n g t - t h e f - l l - w i n g s c a l e . V u l n e r a b i l i t i e s h a v e i m m e d i a t e s e c u r i t y i m p l i c a t i - n s .


I n f - r m a t i - n a l f i n d i n g s m a y b e f - u n d i n t h e G e n e r a l F i n d i n g s .


**C** **R** **I** **T** **I** **C** **A** **L** V u l n e r a b i l i t i e s t h a t i m m e d i a t e l y r e s u l t i n a l  - s s  - f u s e r f u n d s w i t h m i n i m a l p r e c  - n d i t i  - n s .


E x a m p l e s :


                         - M i s c                          - n f i g u r e d a u t h                          - r i t y                          - r a c c e s s c                          - n t r                          - l v a l i d a t i                          - n .


                         - I m p r                          - p e r l y d e s i g n e d e c                          - n                          - m i c i n c e n t i v e s l e a d i n g t                          - l                          - s s                          - f f u n d s .



**H** **I** **G** **H**



V u l n e r a b i l i t i e s t h a t m a y r e s u l t i n a l - s s - f u s e r f u n d s b u t a r e p - t e n t i a l l y d i f f i c u l t t - e x p l - i t .


E x a m p l e s :


    - L     - s s     - f f u n d s r e q u i r i n g s p e c i f i c v i c t i m i n t e r a c t i     - n s .


    - E x p l     - i t a t i     - n i n v     - l v i n g h i g h c a p i t a l r e q u i r e m e n t w i t h r e s p e c t t     - p a y     - u t .



**M** **E** **D** **I** **U** **M** V u l n e r a b i l i t i e s t h a t m a y r e s u l t i n d e n i a l  - f s e r v i c e s c e n a r i  - s  - r d e g r a d e d u s a b i l i t y .


E x a m p l e s :


                         - C                          - m p u t a t i                          - n a l l i m i t e x h a u s t i                          - n t h r                          - u g h m a l i c i                          - u s i n p u t .


                         - F                          - r c e d e x c e p t i                          - n s i n t h e n                          - r m a l u s e r f l                          - w .


**L** **O** **W** L  - w p r  - b a b i l i t y v u l n e r a b i l i t i e s, w h i c h a r e s t i l l e x p l  - i t a b l e b u t r e q u i r e e x t e n u a t i n g c i r c u m s t a n c e s


                    - r u n d u e r i s k .


E x a m p l e s :


                         - O r a c l e m a n i p u l a t i                          - n w i t h l a r g e c a p i t a l r e q u i r e m e n t s a n d m u l t i p l e t r a n s a c t i                          - n s .


**I** **N** **F** **O** B e s t p r a c t i c e s t    - m i t i g a t e f u t u r e s e c u r i t y r i s k s . T h e s e a r e c l a s s i f i e d a s g e n e r a l f i n d i n g s .


E x a m p l e s :


                         - E x p l i c i t a s s e r t i                          - n                          - f c r i t i c a l i n t e r n a l i n v a r i a n t s .


                         - I m p r                          - v e d i n p u t v a l i d a t i                          - n .


© 2 0 2 4 O t t e r A u d i t s L L C . A l l R i g h t s R e s e r v e d . 7 / 8


**B** **—** **P** **r** **o** **c** **e** **d** **u** **r** **e**


A s p a r t - f - u r s t a n d a r d a u d i t i n g p r - c e d u r e, w e s p l i t - u r a n a l y s i s i n t - t w - m a i n s e c t i - n s : d e s i g n a n d


i m p l e m e n t a t i - n .


W h e n a u d i t i n g t h e d e s i g n - f a p r - g r a m, w e a i m t - e n s u r e t h a t t h e - v e r a l l e c - n - m i c a r c h i t e c t u r e i s s - u n d


i n t h e c - n t e x t - f a n - n - c h a i n p r - g r a m . I n - t h e r w - r d s, t h e r e i s n - w a y t - s t e a l f u n d s - r d e n y s e r v i c e,


i g n - r i n g a n y c h a i n - s p e c i f i c q u i r k s . T h i s u s u a l l y r e q u i r e s a d e e p u n d e r s t a n d i n g - f t h e p r - g r a m ’s i n t e r n a l


i n t e r a c t i - n s, p - t e n t i a l g a m e t h e - r y i m p l i c a t i - n s, a n d g e n e r a l - n - c h a i n e x e c u t i - n p r i m i t i v e s .


O n e e x a m p l e - f a d e s i g n v u l n e r a b i l i t y w - u l d b e a n - n - c h a i n - r a c l e t h a t c - u l d b e m a n i p u l a t e d b y f l a s h


l - a n s - r l a r g e d e p - s i t s . S u c h a d e s i g n w - u l d g e n e r a l l y b e u n s - u n d r e g a r d l e s s - f w h i c h c h a i n t h e - r a c l e i s


d e p l - y e d - n .


O n t h e - t h e r h a n d, a u d i t i n g t h e p r - g r a m ’s i m p l e m e n t a t i - n r e q u i r e s a d e e p u n d e r s t a n d i n g - f t h e c h a i n ’s


e x e c u t i - n m - d e l . W h i l e t h i s v a r i e s f r - m c h a i n t - c h a i n, s - m e c - m m - n i m p l e m e n t a t i - n v u l n e r a b i l i t i e s


i n c l u d e r e e n t r a n c y, a c c - u n t - w n e r s h i p i s s u e s, a r i t h m e t i c - v e r f l - w s, a n d r - u n d i n g b u g s .


A s a g e n e r a l r u l e - f t h u m b, i m p l e m e n t a t i - n v u l n e r a b i l i t i e s t e n d t - b e m - r e “ c h e c k l i s t ” s t y l e . I n c - n t r a s t,


d e s i g n v u l n e r a b i l i t i e s r e q u i r e a s t r - n g u n d e r s t a n d i n g - f t h e u n d e r l y i n g s y s t e m a n d t h e v a r i - u s i n t e r a c t i - n s :


b - t h w i t h t h e u s e r a n d c r - s s - p r - g r a m .


A s w e a p p r - a c h a n y n e w t a r g e t, w e s t r i v e t - c - m p r e h e n s i v e l y u n d e r s t a n d t h e p r - g r a m f i r s t . I n - u r a u d i t s,


w e a l w a y s a p p r - a c h t a r g e t s w i t h a t e a m - f a u d i t - r s . T h i s a l l - w s u s t - s h a r e t h - u g h t s a n d c - l l a b - r a t e,


p i c k i n g u p - n d e t a i l s t h a t t h e - t h e r m i s s e d .


W h i l e s - m e t i m e s t h e l i n e b e t w e e n d e s i g n a n d i m p l e m e n t a t i - n c a n b e b l u r r y, w e h - p e t h i s g i v e s s - m e


i n s i g h t i n t - - u r a u d i t i n g p r - c e d u r e a n d t h - u g h t p r - c e s s .


© 2 0 2 4 O t t e r A u d i t s L L C . A l l R i g h t s R e s e r v e d . 8 / 8


