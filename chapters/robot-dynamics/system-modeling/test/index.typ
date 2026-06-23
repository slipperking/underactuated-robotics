#import "/lib.typ": *

#show: docs-subsubchapter.with(
  title: [Test $2 ii ee^(ii theta)$],
  route: "test",
  description: "State-space modeling and control-affine dynamics.",
)

Usually, controlling a system involves using a loop that adjusts the input of the system by observing the state of the system. How exactly the observants affect the input and how to design this relationship to change the system to a desired state is the study of control theory.

The mathematical background consists mainly of nonlinear differential equations and linear algebra.

Mostly, for differential equations, we will consider how the state vector would change given the current state vector and the control input.

Let $vb(x)$ be the state vector, and let $vb(u)$ be the set of control inputs. Then this relationship is modelled by some function $f$ of $vb(x)$ and $vb(u)$ with $ dot(vb(x)) = vb(f)(vb(x), vb(u)). $

In the linear case, $ dot(vb(x)) = vb(A x + B u). $

In many mechanical systems, by virtue of Newton's second law, which states that force changes the second-order derivative of position, $dot.double(vb(q))$, depends on both the generalized positions $vb(q)$, and the generalized velocities $dot(vb(q))$. Therefore, $ dot.double(vb(q)) = vb(f)(vb(q), dot(vb(q)), vb(u)), $ as a second-order system. The state of a system comprises not only the positions, but their velocities. Then we write that
$
  vb(x) = mat(vb(q); dot(vb(q))), quad "and" quad vb(x) = mat(dot(vb(q)); dot.double(vb(q))) = mat(dot(vb(q)); vb(f)(vb(q), dot(vb(q)), dot(vb(u)))).
$
If $vb(u)$ represents the motor torques (for example), and the generalized positions measure angles, then this is typically written as
$
  dot.double(vb(q)) = vb(f)_1(vb(q), dot(vb(q))) + vb(f)_2 (vb(q), dot(vb(q))) vb(u), #tag[$(dagger)$]
$
where $vb(f_1)(dot) in RR^m$ is a vector with dimensionality matching $vb(q) in RR^m$, and $vb(f_1)$ is a matrix of dimension $m times n$.

_Affinity_ is perceived with respect to the control input $vb(u) in RR^n$ (hence _control affine_), and the equation above is affine in $vb(u)$ since it is a linear transformation of it.

#explicit-label(<def:qqq>, definition([Much], restate: true, restate-keys: ("test",))[
  Ah vous dirai je maman
])
Obviously, in the case that $vb(f)_2$ has more rows ($m$) than columns ($n$), then the rank of $vb(f)_2$ is at most $n$, whereas the dimensionality of $vb(q)$, or $m$, is greater than $n$. Thus, in this case the system will always be underactuated. We provide a heuristic or intuitive explanation; since there are less control inputs than the positions we wish to control, we do not _have full control_ of the system. Refer to // @def:qqq
