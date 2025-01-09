import {createWebHistory, createRouter} from "vue-router";

import ManagerPage from "@/components/ManagerPage.vue";
import UserPage from "@/components/UserPage.vue";
import HomePage from "@/components/HomePage.vue";

const routes = [
    {
        path: "/userPage",
        component: UserPage,
        meta: {
            title: "Пользователь"
        }
    },
    {
        path: "/managerPage",
        component: ManagerPage,
        meta: {
            title: "Менеджер"
        }
    },
    {
        path: "/",
        component: HomePage,
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach((to, from, next) => {
    const isLoggedIn = localStorage.getItem("LogIn") === "true";
    if (to.meta.requiresAuth && !isLoggedIn) {
        next('/');
    } else {
        next();
    }
});

export default router;